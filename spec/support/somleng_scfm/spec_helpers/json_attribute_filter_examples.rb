RSpec.shared_examples_for "json_attribute_filter" do
  def json_data
    defined?(super) ? super : {"foo" => "bar", "bar" => "foo"}
  end

  let(:resource) { create(filterable_factory, filterable_attribute => json_data) }

  def setup_scenario
    resource
  end

  def filter_params
    super.merge(filterable_attribute => json_params)
  end

  def assert_filter!
    expect(subject.resources).to match_array(asserted_results)
  end

  context "finding" do
    let(:json_params) { Hash[[json_data.first]] }
    let(:asserted_results) { [resource] }
    it { assert_filter! }
  end

  context "not finding" do
    let(:json_params) { {"foo" => "baz"} }
    let(:asserted_results) { [] }
    it { assert_filter! }
  end
end
