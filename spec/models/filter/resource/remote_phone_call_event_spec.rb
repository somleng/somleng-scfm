require "rails_helper"

RSpec.describe Filter::Resource::RemotePhoneCallEvent do
  let(:filterable_factory) { :remote_phone_call_event }
  let(:association_chain) { RemotePhoneCallEvent.all }

  describe "#resources" do
    include_examples("metadata_attribute_filter")
    include_examples("timestamp_attribute_filter")
    include_examples(
      "string_attribute_filter",
      call_flow_logic: CallFlowLogic::HelloWorld.to_s,
      remote_call_id: SecureRandom.uuid,
      remote_direction: PhoneCall::TWILIO_DIRECTIONS[:inbound]
    )

    it "filters by json" do
      remote_phone_call_event = create(:remote_phone_call_event)
      event_details = remote_phone_call_event.details

      expect(
        build_filter(details: event_details.slice(event_details.keys.first)).resources
      ).to match_array([remote_phone_call_event])

      expect(
        build_filter(details: { "foo" => "baz" }).resources
      ).to match_array([])
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
