require "rails_helper"

RSpec.resource "Contacts" do
  header("Content-Type", "application/json")

  get "/api/contacts" do
    example "List all Contacts" do
      filtered_contact = create(:contact, account: account, metadata: { "foo" => "bar" })

      create(:contact, account: account)
      create(:contact)

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" }
        }
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_contact.id)
    end
  end

  get "/api/callouts/:callout_id/contacts" do
    example "List Contacts in a callout", document: false do
      callout = create(:callout, account: account)
      contact = create(:contact, account: account)
      _callout_participation = create_callout_participation(
        account: account,
        callout: callout,
        contact: contact
      )
      _other_contact = create(:contact, account: account)

      set_authorization_header(access_token: access_token)
      do_request(callout_id: callout.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(contact.id)
    end
  end

  get "/api/batch_operations/:batch_operation_id/contacts" do
    example "List Contacts populated by a callout population", document: false do
      callout_population = create(:callout_population, account: account)
      callout_participation = create_callout_participation(
        account: account,
        callout_population: callout_population
      )
      _other_callout_participation = create_callout_participation(account: account)

      set_authorization_header(access_token: access_token)
      do_request(batch_operation_id: callout_population.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(callout_participation.contact_id)
    end

    example "List Contacts to be called by a phone call create batch operation", document: false do
      batch_operation = create(:phone_call_create_batch_operation, account: account)
      phone_call = create_phone_call(
        account: account,
        create_batch_operation: batch_operation
      )
      _other_contact = create(:contact, account: account)

      set_authorization_header(access_token: access_token)
      do_request(batch_operation_id: batch_operation.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(phone_call.contact_id)
    end
  end

  post "/api/contacts" do
    parameter(
      :msisdn,
      "Phone number in [E.164](https://en.wikipedia.org/wiki/E.164) format",
      required: true
    )

    example "Create a Contact" do
      request_body = {
        msisdn: generate(:somali_msisdn),
        metadata: {
          "gender" => "f",
          "name" => "Kate"
        }
      }

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_contact = account.contacts.find(parsed_response.fetch("id"))
      expect(created_contact.msisdn).to include(request_body.fetch(:msisdn))
      expect(created_contact.metadata).to eq(request_body.fetch(:metadata))
    end

    example "Create an invalid Contact", document: false do
      set_authorization_header(access_token: access_token)
      do_request

      expect(response_status).to eq(422)
    end
  end

  get "/api/contacts/:id" do
    example "Retrieve a Contact" do
      contact = create(:contact, account: account)

      set_authorization_header(access_token: access_token)
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
      contact = create(
        :contact,
        account: account,
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

      set_authorization_header(access_token: access_token)
      do_request(id: contact.id, **request_body)

      expect(response_status).to eq(204)
      contact.reload
      expect(contact.metadata).to eq(request_body.fetch(:metadata))
    end

    example "Update a Contact with invalid data", document: false do
      contact = create(:contact, account: account)
      request_body = { msisdn: "1234" }

      set_authorization_header(access_token: access_token)
      do_request(id: contact.id, **request_body)

      expect(response_status).to eq(422)
    end
  end

  post "/api/contact_data" do
    example "Create or update a Contact" do
      explanation "Creates or updates a contact. If a contact is found with the `msisdn`, it is updated, otherwise it is created."

      request_body = {
        msisdn: generate(:somali_msisdn),
        metadata: {
          "gender" => "f",
          "name" => "Kate"
        }
      }

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_contact = account.contacts.find(parsed_response.fetch("id"))
      expect(created_contact.msisdn).to include(request_body.fetch(:msisdn))
      expect(created_contact.metadata).to eq(request_body.fetch(:metadata))
    end

    example "Update a Contact by data", document: false do
      msisdn = generate(:somali_msisdn)
      contact = create(:contact, account: account, msisdn: msisdn, metadata: { "bar" => "foo" })
      request_body = { msisdn: msisdn, metadata_merge_mode: "replace", metadata: { "foo" => "bar" } }

      set_authorization_header(access_token: access_token)
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
      contact = create(:contact, account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: contact.id)

      expect(response_status).to eq(204)
      expect(Contact.find_by_id(contact.id)).to eq(nil)
    end

    example "Delete a Contact with phone calls", document: false do
      contact = create(:contact, account: account)
      _phone_call = create_phone_call(account: account, contact: contact)

      set_authorization_header(access_token: access_token)
      do_request(id: contact.id)

      expect(response_status).to eq(422)
    end
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[contacts_read contacts_write],
      **options
    )
  end
end
