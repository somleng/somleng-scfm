require 'rails_helper'

RSpec.describe Filter::Resource::RemotePhoneCallEvent do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :remote_phone_call_event }
  let(:association_chain) { RemotePhoneCallEvent }

  describe "#resources" do
    include_examples("metadata_attribute_filter")
    include_examples("timestamp_attribute_filter")
    include_examples(
      "string_attribute_filter",
      :call_flow_logic => CallFlowLogic::Application.to_s,
      :remote_call_id => SecureRandom.uuid,
      :remote_direction => PhoneCall::TWILIO_DIRECTIONS[:inbound],
    )

    context "filtering by details" do
      let(:filterable_attribute) { :details }
      let(:json_data) { generate(:twilio_remote_call_event_details) }
      include_examples "json_attribute_filter"
    end

    describe "filtering" do
      let(:factory_attributes) { {} }
      let(:filterable) { create(filterable_factory, factory_attributes) }
      let(:asserted_results) { [phone_call] }

      def setup_scenario
        super
        phone_call
      end

      def assert_results!
        expect(subject.resources).to match_array([filterable])
      end

      context "by phone_call_id" do
        let(:phone_call) { create(:phone_call) }
        let(:factory_attributes) { { :phone_call => phone_call } }

        def filter_params
          super.merge(:phone_call_id => phone_call.id)
        end

        it { assert_results! }
      end
    end
  end
end
