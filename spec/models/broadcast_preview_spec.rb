require "rails_helper"

RSpec.describe BroadcastPreview do
  it "preview a broadcast" do
    account = create(:account)
    beneficiary = create(:beneficiary, account:, gender: "F")
    create(:beneficiary, :disabled, account:, gender: "F")
    create(:beneficiary, account:, gender: "F")
    beneficiary_in_group = create(:beneficiary, account:, gender: "M")
    beneficiary_group = create(:beneficiary_group, account:)
    create(:beneficiary, account:, gender: "M")
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: beneficiary_in_group)
    create(:beneficiary_address, beneficiary:, iso_region_code: "KH-12")

    broadcast = create(
      :broadcast,
      status: :queued,
      account:,
      beneficiary_filter: {
        gender: { eq: "F" }
      },
      beneficiary_groups: [ beneficiary_group ],
      target_areas: {
        geocode: [
          { iso_region_code: "KH-12" },
          {
            iso_region_code: "KH-2",
            administrative_division_level_2_code: "0201"
          }
        ]
      }
    )

    preview = BroadcastPreview.new(broadcast)

    expect(preview.filtered_beneficiaries).to contain_exactly(beneficiary)
    expect(preview.group_beneficiaries).to contain_exactly(beneficiary_in_group)
    expect(preview.beneficiaries).to contain_exactly(beneficiary, beneficiary_in_group)
  end

  it "handles empty beneficiary filters" do
    beneficiary = create(:beneficiary)
    broadcast = create(
      :broadcast,
      status: :queued,
      account: beneficiary.account,
      beneficiary_filter: {},
      target_areas: {}
    )

    preview = BroadcastPreview.new(broadcast)

    expect(preview.filtered_beneficiaries).to be_empty
  end

  it "handles target areas only" do
    beneficiary = create(:beneficiary)
    create(:beneficiary_address, beneficiary:, iso_region_code: "KH-1")
    broadcast = create(
      :broadcast,
      status: :queued,
      account: beneficiary.account,
      beneficiary_filter: {},
      target_areas: {
        geocode: [
          { iso_region_code: "KH-1" }
        ]
      }
    )

    preview = BroadcastPreview.new(broadcast)

    expect(preview.filtered_beneficiaries).to contain_exactly(beneficiary)
  end

  it "handles beneficiary filters only" do
    beneficiary = create(:beneficiary, gender: "F")
    broadcast = create(
      :broadcast,
      status: :queued,
      account: beneficiary.account,
      beneficiary_filter: {
        gender: { eq: "F" }
      }
    )

    preview = BroadcastPreview.new(broadcast)

    expect(preview.filtered_beneficiaries).to contain_exactly(beneficiary)
  end
end
