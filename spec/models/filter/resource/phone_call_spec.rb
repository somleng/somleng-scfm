require 'rails_helper'

RSpec.describe Filter::Resource::PhoneCall do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :phone_call }
  let(:association_chain) { PhoneCall }

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
      :call_flow_logic => CallFlowLogic::Application.to_s,
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

    context "filtering by remote_request_params" do
      let(:filterable_attribute) { :remote_request_params }
      let(:json_data) { generate(:twilio_request_params) }
      include_examples "json_attribute_filter"
    end

    describe "filtering" do
      let(:factory_attributes) { {} }
      let(:phone_call) { create(filterable_factory, factory_attributes) }
      let(:asserted_results) { [phone_call] }

      def setup_scenario
        super
        create(filterable_factory)
        phone_call
      end

      def assert_filter!
        expect(subject.resources).to match_array(asserted_results)
      end

      context "by callout_participation_id" do
        let(:callout_participation) { create(:callout_participation) }
        let(:factory_attributes) { { :callout_participation => callout_participation } }

        def filter_params
          super.merge(:callout_participation_id => callout_participation.id)
        end

        it { assert_filter! }
      end

      context "by contact_id" do
        let(:contact) { create(:contact) }
        let(:factory_attributes) { { :contact => contact } }

        def filter_params
          super.merge(:contact_id => contact.id)
        end

        it { assert_filter! }
      end
    end
  end
end
