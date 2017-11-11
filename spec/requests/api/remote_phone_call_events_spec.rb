require 'rails_helper'

RSpec.describe "POST '/api/remote_phone_call_events'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:call_sid) { "ff792674-48c9-4146-a953-ffa99a79c14c" }
  let(:from) { nil }
  let(:to) { nil }
  let(:direction) { nil }

  let(:twilio_request_auth_token) { "abcdefg" }
  let(:twilio_request_validator) { Twilio::Security::RequestValidator.new(twilio_request_auth_token) }
  let(:url_options) { {} }
  let(:url) { api_remote_phone_call_events_url(url_options) }
  let(:twilio_request_signature) { twilio_request_validator.build_signature_for(url, params) }
  let(:execute_request) { true }
  let(:authorization_user) { nil }
  let(:authorization_password) { nil }

  def do_post!
    do_request(:post, url, params, headers)
  end

  def setup_scenario
    super
    do_post! if execute_request
  end

  def env
    super.merge(
      "TWILIO_REQUEST_AUTH_TOKEN" => twilio_request_auth_token
    )
  end

  def params
    {
      "CallSid" => call_sid,
      "From" => from,
      "To" => to,
      "Direction" => direction
    }
  end

  def headers
    {
      "X-Twilio-Signature" => twilio_request_signature
    }
  end

  context "requesting json" do
    let(:url_options) { {:format => :json} }
    let(:execute_request) { false }
    let(:asserted_response_body) { asserted_remote_phone_call_event.to_json }
    it { expect { do_post! }.to raise_error(ActionController::UnknownFormat) }
  end

  context "unauthorized request" do
    let(:twilio_request_signature) { "wrong" }

    def assert_unauthorized!
      expect(response.code).to eq("403")
    end

    it { assert_unauthorized! }
  end

  context "invalid request" do
    def assert_invalid!
      expect(response.code).to eq("422")
      xml_response = Hash.from_xml(response.body)
      expect(xml_response["errors"]).to be_present
    end

    it { assert_invalid! }
  end

  context "valid request" do
    let(:application_twiml) { CallFlowLogic::Application.new(asserted_remote_phone_call_event).to_xml }
    let(:asserted_twiml) { application_twiml }
    let(:asserted_response_body) { asserted_twiml }
    let(:asserted_remote_phone_call_event) { RemotePhoneCallEvent.last }

    def assert_created!
      expect(response.code).to eq("201")
      expect(response.headers).not_to have_key("Location")
      expect(asserted_remote_phone_call_event.details).to eq(params)
      expect(asserted_phone_call).to be_present
      expect(asserted_phone_call.remote_call_id).to eq(call_sid)
      expect(asserted_phone_call.remote_direction).to eq(direction)
      expect(asserted_contact).to be_present
      expect(asserted_contact.msisdn).to eq(asserted_contact_msisdn)
      expect(response.body).to eq(asserted_response_body)
    end

    context "for an inbound call" do
      let(:from) { "+85510202101" }
      let(:to) { "345" }
      let(:direction) { "inbound" }

      let(:asserted_phone_call) { asserted_remote_phone_call_event.phone_call }
      let(:asserted_contact) { asserted_phone_call.contact }
      let(:asserted_contact_msisdn) { from }

      it { assert_created! }
    end

    context "for an outbound call" do
      class MyCallFlowLogic < CallFlowLogic::Base
        def to_xml(options = {})
          Twilio::TwiML::VoiceResponse.new do |response|
            response.say("Thanks for trying my custom call flow logic. Enjoy")
          end.to_s
        end
      end

      let(:from) { "345" }
      let(:to) { "+85510202101" }
      let(:direction) { "outbound-api" }

      let(:contact) { create(:contact) }
      let(:call_flow_logic) { nil }
      let(:callout) { create(:callout, :metadata => {:call_flow_logic => call_flow_logic.to_s}) }
      let(:callout_participation) { create(:callout_participation, :callout => callout) }

      let(:phone_call) {
        create(
          :phone_call,
          :remote_call_id => call_sid,
          :remote_direction => direction,
          :contact => contact,
          :callout_participation => callout_participation
        )
      }

      let(:asserted_phone_call) { phone_call }
      let(:asserted_contact) { contact }
      let(:asserted_contact_msisdn) { contact.msisdn }

      def setup_scenario
        phone_call
        super
      end

      context "Setting the call_flow_logic to a valid class" do
        let(:call_flow_logic) { MyCallFlowLogic }
        let(:asserted_twiml) { MyCallFlowLogic.new(asserted_remote_phone_call_event).to_xml }
        it { assert_created! }
      end

      context "Setting the call_flow_logic to an invalid class" do
        let(:call_flow_logic) { PhoneCall }
        it { assert_created! }
      end

      context "Not setting the call_flow_logic" do
        it { assert_created! }
      end
    end
  end
end
