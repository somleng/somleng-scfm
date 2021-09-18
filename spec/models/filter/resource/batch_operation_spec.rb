require "rails_helper"

module Filter
  module Resource
    RSpec.describe BatchOperation do
      let(:filterable_factory) { :callout_population }
      let(:association_chain) { ::BatchOperation::Base.all }

      describe "#resources" do
        include_examples "metadata_attribute_filter"
        include_examples "timestamp_attribute_filter"

        context "filtering by parameters" do
          let(:filterable_attribute) { :parameters }

          include_examples "json_attribute_filter"
        end
      end

      it "filters by callout_id" do
        callout = create(:callout)
        callout_population = create(:callout_population, callout: callout)
        create(:callout_population)
        filter = build_filter(callout_id: callout.id)

        results = filter.resources

        expect(results).to match_array([callout_population])
      end

      it "filters by status" do
        callout_population = create(:callout_population, :finished)
        create(:callout_population, :preview)
        filter = build_filter(status: :finished)

        results = filter.resources

        expect(results).to match_array([callout_population])
      end

      def build_filter(params)
        Filter::Resource::BatchOperation.new({ association_chain: ::BatchOperation::Base }, params)
      end
    end
  end
end
