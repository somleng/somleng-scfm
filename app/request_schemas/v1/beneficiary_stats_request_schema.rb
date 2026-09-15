module V1
  class BeneficiaryStatsRequestSchema < ApplicationRequestSchema
    option :beneficiary_address_validator, default: -> { BeneficiaryAddressValidator.new }
    option :output_serializer, default: -> {
      StatsRequestSchemaOutputSerializer.new(
        filter_class: BeneficiaryFilter,
        field_definitions: FieldDefinitions::BeneficiaryFields
      )
    }

    GROUPS = [
      "gender",
      "disability_status",
      "iso_language_code",
      "iso_country_code",
      "address.iso_region_code",
      "address.administrative_division_level_2_code",
      "address.administrative_division_level_2_name",
      "address.administrative_division_level_3_code",
      "address.administrative_division_level_3_name",
      "address.administrative_division_level_4_code",
      "address.administrative_division_level_4_name",
      "address.administrative_division_level_5_code",
      "address.administrative_division_level_5_name"
    ].freeze

    params do
      optional(:filter).schema(BeneficiaryFilter.schema)
      required(:group_by).value(array[:string])
    end

    rule(:filter).validate(contract: BeneficiaryFilter)

    rule(:group_by) do
      next key.failure("is invalid") unless value.all? { |group| group.in?(GROUPS) }

      address_groups = value.select { |group| group.start_with?("address.") }
      next if address_groups.empty?
      next key.failure("address.iso_region_code is required") unless value.include?("address.iso_region_code")

      address_attributes = address_groups.each_with_object({}) do |group, result|
        _prefix, column = group.split(".")
        result[column] = true
      end
      next if beneficiary_address_validator.valid?(address_attributes)
      key.failure("address.#{beneficiary_address_validator.errors.first.key} is required")
    end

    def output
      output_serializer.serialize(super)
    end
  end
end
