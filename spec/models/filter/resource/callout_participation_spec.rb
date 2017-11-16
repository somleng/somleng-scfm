require 'rails_helper'

RSpec.describe Filter::Resource::CalloutParticipation do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :callout_participation }
  let(:association_chain) { CalloutParticipation }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"
    include_examples "timestamp_attribute_filter"
    include_examples(
      "string_attribute_filter",
      :call_flow_logic => CallFlowLogic::Application.to_s
    )

    context "filtering" do
      let(:factory_attributes) { {} }
      let(:callout_participation) { create(filterable_factory, factory_attributes) }
      let(:asserted_results) { [callout_participation] }
      let(:non_matching_callout_participation) { create(filterable_factory) }

      def setup_scenario
        non_matching_callout_participation
        callout_participation
      end

      def assert_filter!
        expect(subject.resources).to match_array(asserted_results)
      end

      context "filtering by callout_id" do
        let(:callout) { create(:callout) }
        let(:factory_attributes) { { :callout => callout } }

        def filter_params
          super.merge(:callout_id => callout.id)
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

      context "filtering by callout_population_id" do
        let(:callout_population) { create(:callout_population) }
        let(:factory_attributes) { { :callout_population => callout_population } }

        def filter_params
          super.merge(:callout_population_id => callout_population.id)
        end

        it { assert_filter! }
      end

      context "filtering by has_phone_calls" do
        def setup_scenario
          super
          create(:phone_call, :callout_participation => callout_participation)
        end

        def filter_params
          super.merge(:has_phone_calls => "true")
        end

        it { assert_filter! }
      end

      context "last_phone_call_attempt" do
        let(:phone_call) {
          create(
            :phone_call,
            :callout_participation => callout_participation,
            :status => PhoneCall::STATE_FAILED
          )
        }

        def setup_scenario
          super
          phone_call
        end

        context "filtering by last_phone_call_attempt" do
          def filter_params
            super.merge(:last_phone_call_attempt => " failed,  errored  ")
          end

          it { assert_filter! }
        end

        context "filtering by no_phone_calls_or_last_phone_attempt" do
          def filter_params
            super.merge(:no_phone_calls_or_last_attempt => filter_value)
          end

          context "no phone calls" do
            let(:filter_value) { "errored" }
            let(:asserted_results) { [non_matching_callout_participation] }
            it { assert_filter! }
          end

          context "last attempt" do
            let(:filter_value) { "failed" }
            let(:asserted_results) { [callout_participation, non_matching_callout_participation] }
            it { assert_filter! }
          end
        end
      end
    end
  end
end
