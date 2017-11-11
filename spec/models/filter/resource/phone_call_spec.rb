require 'rails_helper'

RSpec.describe Filter::Resource::PhoneCall do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :phone_call }
  let(:association_chain) { PhoneCall }

  it_behaves_like "metadata_attribute_filter"

  describe "#resources" do
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

    context "filtering by callout_participation_id" do
      let(:callout_participation) { create(:callout_participation) }
      let(:factory_attributes) { { :callout_participation => callout_participation } }

      def filter_params
        super.merge(:callout_participation_id => callout_participation.id)
      end

      it { assert_filter! }
    end

    context "filtering by contact_id" do
      let(:contact) { create(:contact) }
      let(:factory_attributes) { { :contact => contact } }

      def filter_params
        super.merge(:contact_id => contact.id)
      end

      it { assert_filter! }
    end

    context "filtering by status" do
      let(:status) { PhoneCall::STATE_COMPLETED }
      let(:factory_attributes) { { :status => status } }

      def filter_params
        super.merge(:status => status)
      end

      it { assert_filter! }
    end

    context "filtering by remote_call_id" do
      let(:remote_call_id) { SecureRandom.uuid }
      let(:factory_attributes) { { :remote_call_id => remote_call_id } }

      def filter_params
        super.merge(:remote_call_id => remote_call_id)
      end

      it { assert_filter! }
    end

    context "filtering by remote_status" do
      let(:remote_status) { PhoneCall::TWILIO_CALL_STATUSES[:not_answered] }
      let(:factory_attributes) { { :remote_status => remote_status } }

      def filter_params
        super.merge(:remote_status => remote_status)
      end

      it { assert_filter! }
    end

    context "filtering by remote_direction" do
      let(:remote_direction) { PhoneCall::TWILIO_DIRECTIONS[:inbound] }
      let(:factory_attributes) { { :remote_direction => remote_direction } }

      def filter_params
        super.merge(:remote_direction => remote_direction)
      end

      it { assert_filter! }
    end

    context "filtering by remote_error_message" do
      let(:remote_error_message) { "Some Error" }
      let(:factory_attributes) { { :remote_error_message => remote_error_message } }

      def filter_params
        super.merge(:remote_error_message => remote_error_message)
      end

      it { assert_filter! }
    end

    context "filtering by remote_response" do
      let(:duration) { "100" }

      let(:remote_response) {
        {
          "call_sid" => SecureRandom.uuid,
          "duration" => duration
        }
      }

      let(:factory_attributes) { { :remote_response => remote_response } }

      def filter_params
        super.merge(:remote_response => {:duration => duration})
      end

      it { assert_filter! }
    end
  end
end
