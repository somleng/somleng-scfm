RSpec.shared_examples_for "json_attribute_filter" do
  it "filters by json" do
    filterable = create(
      filterable_factory,
      filterable_attribute => {
        "foo" => "bar",
        "bar" => "foo"
      }
    )

    expect(build_filter("foo" => "bar").resources).to match_array([filterable])
    expect(build_filter("foo" => "baz").resources).to match_array([])
  end

  def build_filter(filter_params)
    described_class.new({ association_chain: association_chain }, filterable_attribute => filter_params)
  end
end
