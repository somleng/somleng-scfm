require 'rails_helper'

RSpec.describe "Remote Phone Call Events" do
  include SomlengScfm::SpecHelpers::RequestHelpers
  let(:execute_request) { true }
  let(:body) { {} }
  let(:headers) { {} }
  let(:remote_phone_call_event) { create(:remote_phone_call_event) }

  def execute_request!
    do_request(method, url, body, headers)
  end

  def setup_scenario
    super
    execute_request! if execute_request
  end

  describe "'/api/remote_phone_call_events/:id'" do
    let(:url) { api_remote_phone_call_event_path(remote_phone_call_event) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body)).to eq(JSON.parse(remote_phone_call_event.to_json))
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:metadata) { { "foo" => "bar" } }
      let(:body) { { :metadata => metadata } }

      def assert_update!
        expect(response.code).to eq("204")
        expect(remote_phone_call_event.reload.metadata).to eq(metadata)
      end

      it { assert_update! }
    end
  end

  describe "'/api/remote_phone_call_events'" do
    let(:url_params) { {} }
    let(:url) { api_remote_phone_call_events_url(url_params) }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like "resource_filtering" do
        let(:filter_on_factory) { :remote_phone_call_event }
      end

      it_behaves_like "authorization"
    end

    describe "POST" do
      let(:method) { :post }
      let(:call_sid) { SecureRandom.hex }
      let(:from) { nil }
      let(:to) { nil }
      let(:direction) { nil }

      let(:twilio_request_auth_token) { "abcdefg" }
      let(:twilio_request_validator) { Twilio::Security::RequestValidator.new(twilio_request_auth_token) }

      let(:twilio_request_signature) { twilio_request_validator.build_signature_for(url, body) }

      let(:authorization_user) { nil }
      let(:authorization_password) { nil }

      def env
        super.merge(
          "TWILIO_REQUEST_AUTH_TOKEN" => twilio_request_auth_token
        )
      end

      def body
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
        let(:url_params) { {:format => :json} }
        let(:execute_request) { false }
        let(:asserted_response_body) { asserted_remote_phone_call_event.to_json }
        it { expect { execute_request! }.to raise_error(ActionController::UnknownFormat) }
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
          expect(asserted_remote_phone_call_event.details).to eq(body)
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
          let(:callout) { create(:callout, :call_flow_logic => call_flow_logic) }
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

          context "setting the call_flow_logic to a valid class" do
            let(:call_flow_logic) { MyCallFlowLogic }
            let(:asserted_twiml) { MyCallFlowLogic.new(asserted_remote_phone_call_event).to_xml }
            it { assert_created! }
          end

          context "not setting the call_flow_logic" do
            it { assert_created! }
          end
        end
      end
    end
  end
end
