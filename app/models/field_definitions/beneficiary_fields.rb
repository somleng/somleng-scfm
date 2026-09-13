module FieldDefinitions
  BeneficiaryFields = Collection.new([
    Field.new(
      name: :phone_number,
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::StringType.define,
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:phone_number],
        )
      ),
      description: "The phone number of the beneficiary.",
      required: true,
      example: "85516200101"
    ),
    Field.new(
      name: :status,
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::ListType.define(type: :string, options: Beneficiary.status.values),
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:status],
        )
      ),
      description: "Must be one of #{Beneficiary.status.values.map { |t| "`#{t}`" }.join(", ")}."
    ),
    Field.new(
      name: :gender,
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::ListType.define(type: Types::UpcaseString, options: Beneficiary.gender.values),
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:gender],
        )
      ),
      description: "Must be one of `M` or `F`."
    ),
    Field.new(
      name: :disability_status,
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::ListType.define(type: :string, options: Beneficiary.disability_status.values),
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:disability_status],
        )
      ),
      description: "Must be one of #{Beneficiary.disability_status.values.map { |t| "`#{t}`" }.join(", ")}."
    ),
    Field.new(
      name: :date_of_birth,
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::ValueType.define(type: :date),
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:date_of_birth],
        )
      ),
      description: "Date of birth in `YYYY-MM-DD` format."
    ),
    Field.new(
      name: :iso_language_code,
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::StringType.define(type: :string, length: 3),
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:iso_language_code],
        )
      ),
      description: "The [ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-3_codes) alpha-3 language code of the beneficiary."
    ),
    Field.new(
      name: :iso_country_code,
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::CountryListType.define(type: Types::UpcaseString, options: Beneficiary.iso_country_code.values),
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:iso_country_code],
        )
      ),
      description: "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary.",
      required: true,
      example: "KH"
    ),
    Field.new(
      name: :created_at,
      filter: Filter.timestamp(
        query: FieldQuery.new(
          arel_column: Beneficiary.arel_table[:created_at],
        )
      ),
      description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the beneficiary was created.",
      read_only: true
    ),
    Field.new(
      name: :iso_region_code,
      prefix: :address,
      filter: BeneficiaryFilter.address(:iso_region_code),
      description: "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the address"
    ),
    Field.new(
      name: :administrative_division_level_2_code,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_2_code),
      description: "The second-level administrative subdivision code of the address (e.g. district code)"
    ),
    Field.new(
      name: :administrative_division_level_3_code,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_3_code),
      description: "The third-level administrative subdivision code of the address (e.g. township code)"
    ),
    Field.new(
      name: :administrative_division_level_4_code,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_4_code),
      description: "The fourth-level administrative subdivision code of the address (e.g. town code)"
    ),
    Field.new(
      name: :administrative_division_level_5_code,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_5_code),
      description: "The fifth-level administrative subdivision code of the address (e.g. village code)"
    ),
    Field.new(
      name: :administrative_division_level_2_name,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_2_name),
      description: "The second-level administrative subdivision name of the address (e.g. district name)"
    ),
    Field.new(
      name: :administrative_division_level_3_name,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_3_name),
      description: "The third-level administrative subdivision name of the address (e.g. township name)"
    ),
    Field.new(
      name: :administrative_division_level_4_name,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_4_name),
      description: "The fourth-level administrative subdivision name of the address (e.g. town name)"
    ),
    Field.new(
      name: :administrative_division_level_5_name,
      prefix: :address,
      filter: BeneficiaryFilter.address(:administrative_division_level_5_name),
      description: "The fifth-level administrative subdivision name of the address (e.g. village name)"
    )
  ])
end
