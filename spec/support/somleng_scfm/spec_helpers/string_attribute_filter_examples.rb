RSpec.shared_examples_for "string_attribute_filter" do |string_attributes|
  string_attributes.each do |string_attribute, test_value|
    it "filters by #{string_attribute}" do
      filter_attribute = string_attribute.to_sym
      filterable = create(filterable_factory, string_attribute => test_value)

      filter = build_filter(filter_attribute => test_value)
      expect(filter.resources).to match_array([filterable])

      filter = build_filter(filter_attribute => "non-matching")
      expect(filter.resources).to match_array([])
    end
  end

  def build_filter(filter_params)
    described_class.new({ association_chain: association_chain }, filter_params)
  end
end
