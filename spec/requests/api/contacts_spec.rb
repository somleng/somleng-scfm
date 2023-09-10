require "rails_helper"

RSpec.resource "Contacts" do
  header("Content-Type", "application/json")

  get "/api/contacts" do
    example "List all Contacts" do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      account_contact = create(:contact, account:)
      create(:contact)

      set_authorization_header(access_token:)
      do_request

      expect(response_status).to eq(200)
      json_response = JSON.parse(response_body)
      expect(json_response.size).to eq(1)
      expect(json_response.dig(0, "id")).to eq(account_contact.id)
    end

    example "Filter contacts by metadata" do
      explanation """
        Filters contacts by the metadata provided in the query.

        Available operators: #{JSONQueryHelpers::OPERATORS.keys.join(', ')}
      """

      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      filtered_contact = create(
        :contact,
        account:,
        metadata: { "registered_districts" => %w[1401] }
      )
      create(
        :contact,
        account:,
        metadata: { "registered_districts" => %w[1403] }
      )

      set_authorization_header(access_token:)
      do_request(
        q: {
          "metadata" => { "registered_districts.any" => %w[1402 1401] }
        }
      )

      expect(response_status).to eq(200)
      json_response = JSON.parse(response_body)
      expect(json_response.size).to eq(1)
      expect(json_response.dig(0, "id")).to eq(filtered_contact.id)
    end
  end

  get "/api/callouts/:callout_id/contacts" do
    example "List Contacts in a callout", document: false do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      callout = create(:callout, account:)
      contact = create(:contact, account:)
      _callout_participation = create_callout_participation(
        account:,
        callout:,
        contact:
      )
      _other_contact = create(:contact, account:)

      set_authorization_header(access_token:)
      do_request(callout_id: callout.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(contact.id)
    end
  end

  post "/api/contacts" do
    parameter(
      :msisdn,
      "Phone number in [E.164](https://en.wikipedia.org/wiki/E.164) format",
      required: true
    )

    example "Create a Contact" do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)

      request_body = {
        msisdn: generate(:somali_msisdn),
        metadata: {
          "gender" => "f",
          "name" => "Kate"
        }
      }

      set_authorization_header(access_token:)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_contact = account.contacts.find(parsed_response.fetch("id"))
      expect(created_contact.msisdn).to include(request_body.fetch(:msisdn))
      expect(created_contact.metadata).to eq(request_body.fetch(:metadata))
    end

    example "Create an invalid Contact", document: false do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)

      set_authorization_header(access_token:)
      do_request

      expect(response_status).to eq(422)
    end
  end

  get "/api/contacts/:id" do
    example "Retrieve a Contact" do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      contact = create(:contact, account:)

      set_authorization_header(access_token:)
      do_request(id: contact.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.contacts.find(parsed_response.fetch("id"))
      ).to eq(contact)
    end
  end

  patch "/api/contacts/:id" do
    example "Update a Contact" do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)

      contact = create(
        :contact,
        account:,
        metadata: {
          "foo" => "bar"
        }
      )

      request_body = {
        metadata: {
          "bar" => "foo"
        },
        metadata_merge_mode: "replace"
      }

      set_authorization_header(access_token:)
      do_request(id: contact.id, **request_body)

      expect(response_status).to eq(204)
      contact.reload
      expect(contact.metadata).to eq(request_body.fetch(:metadata))
    end

    example "Update a Contact with invalid data", document: false do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      contact = create(:contact, account:)
      request_body = { msisdn: "1234" }

      set_authorization_header(access_token:)
      do_request(id: contact.id, **request_body)

      expect(response_status).to eq(422)
    end
  end

  post "/api/contact_data" do
    example "Create or update a Contact" do
      explanation "Creates or updates a contact. If a contact is found with the `msisdn`, it is updated, otherwise it is created."
      account = create(:account)
      access_token = create_access_token(resource_owner: account)

      request_body = {
        msisdn: generate(:somali_msisdn),
        metadata: {
          "gender" => "f",
          "name" => "Kate"
        }
      }

      set_authorization_header(access_token:)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_contact = account.contacts.find(parsed_response.fetch("id"))
      expect(created_contact.msisdn).to include(request_body.fetch(:msisdn))
      expect(created_contact.metadata).to eq(request_body.fetch(:metadata))
    end

    example "Update a Contact by data", document: false do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      msisdn = generate(:somali_msisdn)
      contact = create(:contact, account:, msisdn:, metadata: { "bar" => "foo" })
      request_body = { msisdn:, metadata_merge_mode: "replace",
                       metadata: { "foo" => "bar" } }

      set_authorization_header(access_token:)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      contact.reload
      expect(parsed_response.fetch("id")).to eq(contact.id)
      expect(contact.metadata).to eq(request_body.fetch(:metadata))
    end
  end

  delete "/api/contacts/:id" do
    example "Delete a Contact" do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      contact = create(:contact, account:)

      set_authorization_header(access_token:)
      do_request(id: contact.id)

      expect(response_status).to eq(204)
      expect(Contact.find_by_id(contact.id)).to eq(nil)
    end

    example "Delete a Contact with phone calls", document: false do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      contact = create(:contact, account:)
      _phone_call = create_phone_call(account:, contact:)

      set_authorization_header(access_token:)
      do_request(id: contact.id)

      expect(response_status).to eq(422)
    end
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[contacts_read contacts_write],
      **options
    )
  end
end
