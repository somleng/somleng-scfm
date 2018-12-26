RSpec.shared_examples_for "msisdn_attribute_filter" do
  it "filters by msisdn" do
    filterable = create(filterable_factory)

    expect(build_filter(msisdn: filterable.msisdn).resources).to match_array([filterable])
    expect(build_filter(msisdn: "wronng").resources).to match_array([])
  end

  def build_filter(filter_params)
    described_class.new({ association_chain: association_chain }, filter_params)
  end
end
