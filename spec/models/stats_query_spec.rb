require "rails_helper"

RSpec.describe StatsQuery, type: :model do
  it "return results with a simple group by field" do
    create_list(:beneficiary, 2, gender: "M")
    create_list(:beneficiary, 3, gender: "F")

    result = StatsQuery.new(
      group_by: [
        build_beneficiary_group_by_field(:gender)
      ],
    ).apply(Beneficiary.all)

    expect(result).to contain_exactly(
      have_attributes(groups: [ "gender" ], key: [ "M" ], value: 2),
      have_attributes(groups: [ "gender" ], key: [ "F" ], value: 3),
    )
  end

  it "return results with group by fields that need to be joined" do
    female_beneficiary = create(:beneficiary, gender: "F")
    beneficiary = create(:beneficiary, iso_country_code: "KH", gender: "M")
    create(
      :beneficiary_address,
      beneficiary:,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1201"
    )
    create_list(
      :beneficiary_address,
      2,
      beneficiary:,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1202"
    )
    create(
      :beneficiary_address,
      beneficiary: create(:beneficiary, gender: "M"),
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1202"
    )
    create(
      :beneficiary_address,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1202",
      beneficiary: female_beneficiary
    )

    result = StatsQuery.new(
      filter_group: FilterGroup.new(
        conditions: [
          FilterField.new(
            name: :gender,
            operator: "eq",
            value: "M"
          )
        ]
      ),
      group_by: [
        build_beneficiary_group_by_field(:iso_country_code),
        build_beneficiary_group_by_field(
          "address.iso_region_code",
          arel_column: BeneficiaryAddress.arel_table[:iso_region_code],
          association: :addresses
        ),
        build_beneficiary_group_by_field(
          "address.administrative_division_level_2_code",
          arel_column: BeneficiaryAddress.arel_table[:administrative_division_level_2_code],
          association: :addresses
        )
      ],
    ).apply(Beneficiary.all)

    expect(result).to contain_exactly(
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1202" ], value: 2),
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1201" ], value: 1),
    )
  end

  it "raise an error if the result is too large" do
    stub_const("StatsQuery::MAX_RESULTS", 2)

    beneficiary = create(:beneficiary, iso_country_code: "KH")
    create(
      :beneficiary_address,
      beneficiary:,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1201"
    )
    create_list(
      :beneficiary_address,
      2,
      beneficiary:,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1202"
    )
    create_list(
      :beneficiary_address,
      2,
      beneficiary:,
      iso_region_code: "KH-1",
      administrative_division_level_2_code: "0102"
    )

    expect {
      StatsQuery.new(
        group_by: [
          build_beneficiary_group_by_field(:iso_country_code),
          build_beneficiary_group_by_field(
            "address.iso_region_code",
            arel_column: BeneficiaryAddress.arel_table[:iso_region_code],
            association: :addresses
          ),
          build_beneficiary_group_by_field(
            "address.administrative_division_level_2_code",
            arel_column: BeneficiaryAddress.arel_table[:administrative_division_level_2_code],
            association: :addresses
          )
        ],
      ).apply(Beneficiary.all)
    }.to raise_error(StatsQuery::TooManyResultsError)
  end

  def build_beneficiary_group_by_field(name, arel_column: nil, association: nil)
    GroupByField.new(
      name: name.to_s,
      query: FieldQuery.new(
        arel_column: arel_column || Beneficiary.arel_table[name],
        association:
      )
    )
  end
end
