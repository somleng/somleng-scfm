require "rails_helper"

RSpec.describe Filter::Resource::RemotePhoneCallEvent do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :remote_phone_call_event }
  let(:association_chain) { RemotePhoneCallEvent }

  describe "#resources" do
    include_examples("metadata_attribute_filter")
    include_examples("timestamp_attribute_filter")
    include_examples(
      "string_attribute_filter",
      call_flow_logic: CallFlowLogic::HelloWorld.to_s,
      remote_call_id: SecureRandom.uuid,
      remote_direction: PhoneCall::TWILIO_DIRECTIONS[:inbound]
    )

    context "filtering by details" do
      let(:filterable_attribute) { :details }
      let(:json_data) { generate(:twilio_remote_call_event_details) }

      include_examples "json_attribute_filter"
    end

    it "filters by call_duration" do
      event = create(
        :remote_phone_call_event, call_duration: 9
      )
      create(:remote_phone_call_event, call_duration: 10)
      create(:remote_phone_call_event, call_duration: 8)
      filter = build_filter(call_duration: 9)

      results = filter.resources

      expect(results).to match_array([event])
    end

    it "filters by lt, lteq, gt, gteq call_duration" do
      event = create(:remote_phone_call_event, call_duration: 9)
      create(:remote_phone_call_event, call_duration: 10)
      create(:remote_phone_call_event, call_duration: 8)
      filter = build_filter(call_duration_gteq: 9, call_duration_lt: 10)

      results = filter.resources

      expect(results).to match_array([event])
    end

    it "filters by phone_call_id" do
      event = create(:remote_phone_call_event)
      create(:remote_phone_call_event)
      filter = build_filter(phone_call_id: event.phone_call.id)

      results = filter.resources

      expect(results).to match_array([event])
    end
  end

  def build_filter(params)
    described_class.new({ association_chain: RemotePhoneCallEvent }, params)
  end
end
