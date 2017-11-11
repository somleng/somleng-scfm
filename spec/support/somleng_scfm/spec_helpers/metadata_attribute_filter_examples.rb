RSpec.shared_examples_for "metadata_attribute_filter" do
  context "filtering by metadata" do
    let(:filterable_attribute) { :metadata }
    include_examples("json_attribute_filter")
  end
end
