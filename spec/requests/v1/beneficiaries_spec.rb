require "rails_helper"

RSpec.resource "Beneficiaries"  do
  get "/v1/beneficiaries" do
    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    example "List all active beneficiaries" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      _account_disabled_beneficiary = create(:beneficiary, :disabled, account:)
      _other_account_beneficiary = create(:beneficiary)

      set_authorization_header_for(account)
      do_request(
        filter: {
          status: { eq: "active" }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.fetch("data").pluck("id")).to match_array(
        beneficiary.id.to_s
      )
    end

    example "Filter beneficiaries" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:, gender: "F")
      create(:beneficiary, account:, gender: "M")
      create(:beneficiary, account:, created_at: 5.days.ago)

      set_authorization_header_for(account)
      do_request(filter: { created_at: { gt: 4.days.ago.utc.iso8601 }, gender: { eq: "F" } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        beneficiary.id.to_s
      )
    end

    example "Filter beneficiaries by phone number", document: false do
      account = create(:account)
      beneficiary = create(:beneficiary, account:, phone_number: "855715100888")
      create(:beneficiary, account:)

      set_authorization_header_for(account)
      do_request(filter: { phone_number: { eq: "+855 715 100 888" } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        beneficiary.id.to_s
      )
    end

    example "includes relationships", document: false do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      create(:beneficiary_address, beneficiary:)
      create(:beneficiary_group_membership, beneficiary:, beneficiary_group: create(:beneficiary_group, account:))

      set_authorization_header_for(account)
      do_request(include: "addresses, groups")

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.dig("included", 0).to_json).to match_api_response_schema("beneficiary_address")
      expect(json_response.dig("included", 1).to_json).to match_api_response_schema("beneficiary_group")
    end
  end

  post "/v1/beneficiaries" do
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `beneficiary`",
        required: true,
        method: :_disabled
      )
    end
    with_options scope: %i[data attributes] do
      parameter(
        :phone_number, "Phone number in E.164 format.",
        required: true,
        method: :_disabled
      )
      parameter(
        :iso_country_code, "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary.",
        required: true,
        method: :_disabled
      )
      parameter(
        :iso_language_code, "The [ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) alpha-3 language code of the beneficiary.",
        required: false,
        method: :_disabled
      )
      parameter(
        :gender, "Must be one of `M` or `F`.",
        required: false,
        method: :_disabled
      )
      parameter(
        :status, "If supplied, must be one of #{Beneficiary.status.values.map { |t| "`#{t}`" }.join(", ")}. Only beneficiaries with active status are considered when creating a broadcast.",
        required: false,
        method: :_disabled
      )
      parameter(
        :disability_status, "If supplied, must be one of #{Beneficiary.disability_status.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: false,
        method: :_disabled
      )
      parameter(
        :date_of_birth, "Date of birth in `YYYY-MM-DD` format.",
        required: false,
        method: :_disabled
      )
      parameter(
        :metadata, "Set of key-value pairs that you can attach to the beneficiary. This can be useful for storing additional information about the beneficiary in a structured format.",
        required: false,
        method: :_disabled
      )
    end

    with_options scope: %i[data attributes address] do
      FieldDefinitions::BeneficiaryFields.each do |field|
        next unless field.prefix&.address?

        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    with_options scope: [ :data, :relationships, :groups ] do
      parameter(
        :"data.*.type", "Must be `beneficiary_group`",
        required: false,
        method: :_disabled
      )
      parameter(
        :"data.*.id", "The unique ID of the beneficiary group",
        required: false,
        method: :_disabled
      )
    end

    example "Create a beneficiary" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary,
          attributes: {
            phone_number: "+85510999999",
            iso_language_code: "khm",
            gender: "M",
            date_of_birth: "1990-01-01",
            metadata: { "my_custom_property" => "my_custom_property_value" },
            iso_country_code: "KH",
            disability_status: "none"
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(jsonapi_response_attributes).to include(
        "phone_number" => "85510999999",
        "iso_language_code" => "khm",
        "gender" => "M",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "my_custom_property" => "my_custom_property_value" },
        "iso_country_code" => "KH",
        "disability_status" => "none",
      )
    end

    example "Create a beneficiary with an address" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary,
          attributes: {
            phone_number: "+85510999999",
            iso_country_code: "KH",
            address: {
              iso_region_code: "KH-1",
              administrative_division_level_2_code: "0102",
              administrative_division_level_2_name: "Mongkol Borey",
              administrative_division_level_3_code: "010201",
              administrative_division_level_3_name: "Banteay Neang",
              administrative_division_level_4_code: "01020101",
              administrative_division_level_4_name: "Ou Thum",
              administrative_division_level_5_code: "0102010101",
              administrative_division_level_5_name: "Krom 1"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(jsonapi_response_attributes).to include(
        "phone_number" => "85510999999",
        "iso_country_code" => "KH"
      )

      expect(json_response.dig("included", 0).to_json).to match_api_response_schema("beneficiary_address")
      expect(json_response.dig("included", 0, "attributes")).to include(
        "iso_region_code" => "KH-1",
        "administrative_division_level_2_code" => "0102",
        "administrative_division_level_2_name" => "Mongkol Borey",
        "administrative_division_level_3_code" => "010201",
        "administrative_division_level_3_name" => "Banteay Neang",
        "administrative_division_level_4_code" => "01020101",
        "administrative_division_level_4_name" => "Ou Thum",
        "administrative_division_level_5_code" => "0102010101",
        "administrative_division_level_5_name" => "Krom 1",
      )
    end

    example "Create a beneficiary and add them to a group" do
      account = create(:account)
      group = create(:beneficiary_group, account:)

      set_authorization_header_for(account)

      do_request(
        data: {
          type: :beneficiary,
          attributes: {
            phone_number: "+85510999999",
            iso_country_code: "KH"
          },
          relationships: {
            groups: {
              data: [
                { type: "beneficiary_group", id: group.id }
              ]
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(json_response.dig("data", "relationships", "groups", "data").pluck("id")).to contain_exactly(group.id.to_s)
    end

    example "Fail to create a beneficiary", document: false do
      account = create(:account)
      create(:beneficiary, account:, phone_number: "+85510999999")

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary,
          attributes: {
            phone_number: "+85510999999",
            iso_country_code: "KH"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0)).to include(
        "title" => "must be unique",
        "source" => { "pointer" => "/data/attributes/phone_number" }
      )
    end
  end

  get "/v1/beneficiaries/:id" do
    example "Fetch a beneficiary" do
      beneficiary = create(:beneficiary)

      set_authorization_header_for(beneficiary.account)
      do_request(id: beneficiary.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(json_response.dig("data", "id")).to eq(beneficiary.id.to_s)
    end
  end

  patch "/v1/beneficiaries/:id" do
    with_options scope: %i[data] do
      parameter(
        :id, "The unique identifier of the beneficiary.",
        required: true
      )
      parameter(
        :type, "Must be `beneficiary`",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :phone_number, "Phone number in E.164 format.",
        required: false
      )
      parameter(
        :iso_country_code, "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary.",
        required: false
      )
      parameter(
        :iso_language_code, "The [ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) alpha-3 language code of the beneficiary.",
        required: false
      )
      parameter(
        :gender, "Must be one of `M` or `F`.",
        required: false
      )
      parameter(
        :status, "If supplied, must be one of #{Beneficiary.status.values.map { |t| "`#{t}`" }.join(", ")}. Only beneficiaries with active status are considered when creating a broadcast.",
        required: false,
        method: :_disabled
      )
      parameter(
        :disability_status, "If supplied, must be one of #{Beneficiary.disability_status.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: false
      )
      parameter(
        :date_of_birth, "Date of birth in `YYYY-MM-DD` format.",
        required: false
      )
      parameter(
        :metadata, "Set of key-value pairs that you can attach to the beneficiary. This can be useful for storing additional information about the beneficiary in a structured format.",
        required: false
      )
    end

    example "Update a beneficiary" do
      beneficiary = create(
        :beneficiary,
        phone_number: "+85510999001",
        gender: nil,
        iso_language_code: nil,
        date_of_birth: nil,
        metadata: {}
      )

      set_authorization_header_for(beneficiary.account)
      do_request(
        id: beneficiary.id,
        data: {
          id: beneficiary.id,
          type: :beneficiary,
          attributes: {
            phone_number: "+85510999002",
            gender: "F",
            status: "disabled",
            iso_language_code: "eng",
            date_of_birth: "1990-01-01",
            metadata: {
              foo: "bar"
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(jsonapi_response_attributes).to include(
        "phone_number" => "85510999002",
        "iso_language_code" => "eng",
        "gender" => "F",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "foo" => "bar" }
      )
    end

    example "Disable a beneficiary" do
      beneficiary = create(
        :beneficiary,
        status: :active,
      )

      set_authorization_header_for(beneficiary.account)
      do_request(
        id: beneficiary.id,
        data: {
          id: beneficiary.id,
          type: :beneficiary,
          attributes: {
            status: :disabled
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(jsonapi_response_attributes).to include(
        "status" => "disabled"
      )
    end
  end

  get "/v1/beneficiaries/stats" do
    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    parameter(
      :group_by,
      "An array of fields to group by. Supported fields: #{V1::BeneficiaryStatsRequestSchema::GROUPS.map { |group| "`#{group}`" }.join(", ")}.",
      required: true
    )

    example "Fetch beneficiaries stats" do
      explanation <<~HEREDOC
        This endpoint provides statistical insights into the beneficiaries managed within the OpenEWS system. This endpoint is particularly useful for generating reports, analyzing beneficiary data, and monitoring the scope of your early warning system.

        ### Functionality

        This endpoint returns aggregated statistics about the beneficiaries in your system. Common use cases include:

        - Counting the total number of beneficiaries.
        - Grouping beneficiaries by attributes such as location, gender, or address attributes.
        - Identifying trends or patterns in beneficiary data.

        ### Parameters

        The endpoint may accept query parameters to filter or group the data. Common parameters include:

        - **Filters:** Specify conditions for narrowing down the results. For example, you might filter beneficiaries by a specific region or status.
        - **Group By:** Group the statistics by a particular attribute such as `gender`, `address`, or `disability_status`.
      HEREDOC

      account = create(:account)
      male_beneficiary = create(:beneficiary, account:, gender: "M")
      female_beneficiary = create(:beneficiary, account:, gender: "F")
      create(
        :beneficiary_address,
        beneficiary: male_beneficiary,
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1201"
      )
      create_list(
        :beneficiary_address,
        2,
        beneficiary: male_beneficiary,
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1202"
      )
      create(
        :beneficiary_address,
        beneficiary: create(:beneficiary, account:, gender: "M"),
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1202"
      )
      create_list(
        :beneficiary_address,
        2,
        beneficiary: female_beneficiary,
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0102"
      )

      set_authorization_header_for(account)
      do_request(
        filter: { gender: { eq: "M" }, "address.iso_region_code": { eq: "KH-12" } },
        group_by: [
          "iso_country_code",
          "address.iso_region_code",
          "address.administrative_division_level_2_code"
        ]
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("stat", pagination: false)
      results = json_response.fetch("data").map { |data| data.dig("attributes", "result") }

      expect(results).to contain_exactly(
        {
          "iso_country_code" => "KH",
          "address.iso_region_code" => "KH-12",
          "address.administrative_division_level_2_code" => "1201",
          "value" => 1
        },
        {
          "iso_country_code" => "KH",
          "address.iso_region_code" => "KH-12",
          "address.administrative_division_level_2_code" => "1202",
          "value" => 2
        }
      )
    end

    example "Fetch beneficiaries stats by gender", document: false do
      account = create(:account)
      create_list(:beneficiary, 2, account:, gender: "M")
      create(:beneficiary, account:, gender: "F")

      set_authorization_header_for(account)
      do_request(group_by: [ "gender" ])

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("stat", pagination: false)
      results = json_response.fetch("data").map { |data| data.dig("attributes", "result") }

      expect(results).to contain_exactly(
        {
          "gender" => "M",
          "value" => 2
        },
        {
          "gender" => "F",
          "value" => 1
        }
      )
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(400)
    end

    example "Handles too many results", document: false do
      stub_const("StatsQuery::MAX_RESULTS", 2)
      account = create(:account)
      create(:beneficiary, account:, iso_country_code: "KH")
      create(:beneficiary, account:, iso_country_code: "VN")
      create(:beneficiary, account:, iso_country_code: "AU")

      set_authorization_header_for(account)
      do_request(group_by: [ "iso_country_code" ])

      expect(response_status).to eq(400)
      expect(response_body).to match_api_response_schema("jsonapi_error")
    end
  end

  delete "/v1/beneficiaries/:id" do
    example "Delete a beneficiary" do
      beneficiary = create(:beneficiary)
      create(:beneficiary_address, beneficiary:)

      set_authorization_header_for(beneficiary.account)
      do_request(id: beneficiary.id)

      expect(response_status).to eq(204)
    end
  end

  get "/v1/beneficiaries/:beneficiary_id/addresses" do
    example "List all addresses for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address1 = create(:beneficiary_address, :full, beneficiary:)
      address2 = create(:beneficiary_address, :full, beneficiary:, administrative_division_level_5_code: "0102010102", administrative_division_level_5_name: "Krom 2")
      other_beneficiary = create(:beneficiary)
      _other_address = create(:beneficiary_address, beneficiary: other_beneficiary)

      set_authorization_header_for(account)
      do_request(beneficiary_id: beneficiary.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary_address")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        address1.id.to_s,
        address2.id.to_s
      )
    end
  end

  post "/v1/beneficiaries/:beneficiary_id/addresses" do
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `beneficiary_address`",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      FieldDefinitions::BeneficiaryFields.each do |field|
        next unless field.prefix&.address?
        required = field.name == :iso_region_code ? true : false

        parameter(field.name, field.description, required:, method: :_disabled)
      end
    end

    example "Create an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_id: beneficiary.id,
        data: {
          type: :beneficiary_address,
          attributes: {
            iso_region_code: "KH-1",
            administrative_division_level_2_code: "0102",
            administrative_division_level_2_name: "Mongkol Borey",
            administrative_division_level_3_code: "010201",
            administrative_division_level_3_name: "Banteay Neang",
            administrative_division_level_4_code: "01020101",
            administrative_division_level_4_name: "Ou Thum",
            administrative_division_level_5_code: "0102010101",
            administrative_division_level_5_name: "Krom 1"
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary_address")
      expect(jsonapi_response_attributes).to include(
        "iso_region_code" => "KH-1",
        "administrative_division_level_2_code" => "0102",
        "administrative_division_level_2_name" => "Mongkol Borey",
        "administrative_division_level_3_code" => "010201",
        "administrative_division_level_3_name" => "Banteay Neang",
        "administrative_division_level_4_code" => "01020101",
        "administrative_division_level_4_name" => "Ou Thum",
        "administrative_division_level_5_code" => "0102010101",
        "administrative_division_level_5_name" => "Krom 1"
      )
    end
  end

  get "/v1/beneficiaries/:beneficiary_id/addresses/:id" do
    example "Fetch an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address = create(:beneficiary_address, :full, beneficiary:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_id: beneficiary.id,
        id: address.id
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary_address")
      expect(json_response.dig("data", "id")).to eq(address.id.to_s)
    end
  end

  delete "/v1/beneficiaries/:beneficiary_id/addresses/:id" do
    example "Delete an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address = create(:beneficiary_address, beneficiary:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_id: beneficiary.id,
        id: address.id
      )

      expect(response_status).to eq(204)
    end
  end
end
