require "rails_helper"

RSpec.describe Filter::Resource::PhoneCall do
  let(:filterable_factory) { :phone_call }
  let(:association_chain) { PhoneCall.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"
    include_examples(
      "timestamp_attribute_filter",
      :created_at,
      :updated_at,
      :remotely_queued_at
    )
    include_examples(
      "string_attribute_filter",
      "status" => PhoneCall::STATE_COMPLETED,
      :call_flow_logic => CallFlowLogic::HelloWorld.to_s,
      :remote_call_id => SecureRandom.uuid,
      :remote_status => PhoneCall::TWILIO_CALL_STATUSES[:not_answered],
      :remote_direction => PhoneCall::TWILIO_DIRECTIONS[:inbound],
      :remote_error_message => "Some Error"
    )

    context "filtering by remote_response" do
      let(:filterable_attribute) { :remote_response }

      include_examples "json_attribute_filter"
    end

    context "filtering by remote_queue_response" do
      let(:filterable_attribute) { :remote_queue_response }

      include_examples "json_attribute_filter"
    end

    it "filters by duration" do
      phone_call = create(:phone_call, duration: 10)
      create(:phone_call, duration: 0)
      filter = build_filter(duration: "10")

      results = filter.resources

      expect(results).to match_array([phone_call])
    end

    it "filters by gt, gteq, lt, lteq" do
      phone_call = create(:phone_call, duration: 9)
      create(:phone_call, duration: 10)
      create(:phone_call, duration: 8)
      filter = build_filter(duration_lt: "10", duration_gt: "8")

      results = filter.resources

      expect(results).to match_array([phone_call])
    end

    it "filters by callout_id" do
      callout = create(:callout)
      callout_participation = create(:callout_participation, callout: callout)
      phone_call = create(:phone_call, callout: callout, callout_participation: callout_participation)
      create(:phone_call)
      filter = build_filter(callout_id: callout.id)

      results = filter.resources

      expect(results).to match_array([phone_call])
    end

    it "filters by callout_participation_id" do
      callout_participation = create(:callout_participation)
      phone_call = create(:phone_call, callout_participation: callout_participation)
      create(:phone_call)
      filter = build_filter(callout_participation_id: callout_participation.id)

      results = filter.resources

      expect(results).to match_array([phone_call])
    end

    it "filters by contact_id" do
      contact = create(:contact)
      phone_call = create(:phone_call, contact: contact)
      create(:phone_call)
      filter = build_filter(contact_id: contact.id)

      results = filter.resources

      expect(results).to match_array([phone_call])
    end
  end

  def build_filter(params)
    described_class.new({ association_chain: PhoneCall }, params)
  end
end
