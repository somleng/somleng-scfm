require 'rails_helper'

RSpec.describe Filter::Resource::PhoneCall do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :phone_call }
  let(:association_chain) { PhoneCall }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"

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

      context "by status" do
        let(:status) { PhoneCall::STATE_COMPLETED }
        let(:factory_attributes) { { :status => status } }

        def filter_params
          super.merge(:status => status)
        end

        it { assert_filter! }
      end

      context "by remote_call_id" do
        let(:remote_call_id) { SecureRandom.uuid }
        let(:factory_attributes) { { :remote_call_id => remote_call_id } }

        def filter_params
          super.merge(:remote_call_id => remote_call_id)
        end

        it { assert_filter! }
      end

      context "by remote_status" do
        let(:remote_status) { PhoneCall::TWILIO_CALL_STATUSES[:not_answered] }
        let(:factory_attributes) { { :remote_status => remote_status } }

        def filter_params
          super.merge(:remote_status => remote_status)
        end

        it { assert_filter! }
      end

      context "by remote_direction" do
        let(:remote_direction) { PhoneCall::TWILIO_DIRECTIONS[:inbound] }
        let(:factory_attributes) { { :remote_direction => remote_direction } }

        def filter_params
          super.merge(:remote_direction => remote_direction)
        end

        it { assert_filter! }
      end

      context "by remote_error_message" do
        let(:remote_error_message) { "Some Error" }
        let(:factory_attributes) { { :remote_error_message => remote_error_message } }

        def filter_params
          super.merge(:remote_error_message => remote_error_message)
        end

        it { assert_filter! }
      end
    end
  end
end
