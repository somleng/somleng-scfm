require "rails_helper"

RSpec.describe FilterScope, type: :model do
  it "handles relationships without an association" do
    beneficiary_with_address = create(:beneficiary)
    create(:beneficiary_address, beneficiary: beneficiary_with_address)
    beneficiary_without_address = create(:beneficiary)
    filter_field = FilterField.new(
      name: :iso_region_code,
      query: FieldQuery.new(
        arel_column: BeneficiaryAddress.arel_table[:iso_region_code],
        association: :addresses
      ),
      operator: "is_null",
      value: true
    )
    filter_group = FilterGroup.new(conditions: Array(filter_field))
    query = FilterScope.new(scope: Beneficiary, filter_group:)

    result = query.apply

    expect(result).to contain_exactly(beneficiary_without_address)
  end

  it "returns unique results" do
    beneficiary = create(:beneficiary)
    create_list(:beneficiary_address, 2, beneficiary:, iso_region_code: "KH-1")
    filter_field = FilterField.new(
      name: :iso_region_code,
      query: FieldQuery.new(
        arel_column: BeneficiaryAddress.arel_table[:iso_region_code],
        association: :addresses
      ),
      operator: "in",
      value: [ "KH-1", "KH-2" ]
    )
    filter_group = FilterGroup.new(conditions: Array(filter_field))
    query = FilterScope.new(scope: Beneficiary, filter_group:)

    result = query.apply

    expect(result).to contain_exactly(beneficiary)
  end
end
