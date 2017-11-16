RSpec.shared_examples_for "json_attribute_filter" do
  let(:resource) { create(filterable_factory, filterable_attribute => json_data) }

  def setup_scenario
    resource
  end

  def filter_params
    super.merge(filterable_attribute => json_params)
  end

  def assert_results!
    expect(subject.resources).to match_array([resource])
  end

  def assert_no_results!
    expect(subject.resources).to match_array([])
  end

  context "finding" do
    let(:json_params) { Hash[[json_data.first]] }
    it { assert_results! }
  end

  context "not finding" do
    let(:json_params) { {"foo" => "baz"} }
    it { assert_no_results! }
  end
end
