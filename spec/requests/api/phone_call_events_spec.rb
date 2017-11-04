require 'rails_helper'

RSpec.describe "POST '/api/phone_call_events'" do
  # https://requestb.in/t8ouaut8?inspect

  let(:call_sid) { "ff792674-48c9-4146-a953-ffa99a79c14c" }

  def do_request(method, path, body = {}, headers = {}, options = {})
    public_send(method, path, {:params => body, :headers => headers}.merge(options))
  end

  def setup_scenario
    super
    do_request(:post, api_phone_call_events_path, params)
  end

  def params
    {
      "CallSid" => call_sid,
      "From" => from,
      "To" => to,
      "Direction" => direction
    }
  end

  let(:asserted_phone_call_event) { PhoneCallEvent.last }
  let(:application_twiml) { CallFlowLogic::Application.new(asserted_phone_call_event).to_xml }
  let(:asserted_twiml) { application_twiml }

  def assert_created!
    expect(response.code).to eq("201")
    expect(response.headers).not_to have_key("Location")
    expect(asserted_phone_call_event.details).to eq(params)
    expect(asserted_phone_call).to be_present
    expect(asserted_phone_call.remote_call_id).to eq(call_sid)
    expect(asserted_phone_call.remote_direction).to eq(direction)
    expect(asserted_contact).to be_present
    expect(asserted_contact.msisdn).to eq(asserted_contact_msisdn)
    expect(response.body).to eq(asserted_twiml)
  end

  context "for an inbound call" do
    let(:from) { "+85510202101" }
    let(:to) { "345" }
    let(:direction) { "inbound" }

    let(:asserted_phone_call) { asserted_phone_call_event.phone_call }
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
    let(:callout) { create(:callout, :metadata => {:call_flow_logic => call_flow_logic.to_s}) }

    let(:phone_call) {
      create(
        :phone_call,
        :remote_call_id => call_sid,
        :remote_direction => direction,
        :contact => contact,
        :callout => callout
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
      let(:asserted_twiml) { MyCallFlowLogic.new(asserted_phone_call_event).to_xml }
      it { assert_created! }
    end

    context "Setting the call_flow_logic to an invalid class" do
      let(:call_flow_logic) { PhoneCall }
      it { assert_created! }
    end

    context "Not setting the call_flow_logic" do
      let(:call_flow_logic) { nil }
      it { assert_created! }
    end
  end
end
