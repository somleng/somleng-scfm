RSpec.shared_examples_for "json_attribute_filter" do

  let(:json_data) {
    {
      "foo" => "bar",
      "bar" => "foo"
    }
  }

  let(:resource) { create(filterable_factory, filterable_attribute => json_data) }

  def setup_scenario
    super
    resource
  end

  def filter_params
    super.merge(filterable_attribute => json_params)
  end

  def assert_filter!
    expect(subject.resources).to match_array(asserted_results)
  end

  context "finding" do
    let(:json_params) { {"foo" => "bar"} }
    let(:asserted_results) { [resource] }
    it { assert_filter! }
  end

  context "not finding" do
    let(:json_params) { {"foo" => "baz"} }
    let(:asserted_results) { [] }
    it { assert_filter! }
  end
end
