require "rails_helper"

RSpec.describe "Contacts" do
  fit "can list all contacts" do
    _matching_contact = create(:contact, account: account, metadata: { "foo" => "bar" })
    filtered_contact = create(:contact, account: account, metadata: { "foo" => "bar" })

    create(:contact, account: account)
    create(:contact)

    get(
      api_contacts_path(q: { "metadata" => { "foo" => "bar" } }, sort: "-id,created_at"),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(2)
    expect(parsed_body.first.fetch("id")).to eq(filtered_contact.id)
  end

  it "can list contacts for a callout" do
    callout = create(:callout, account: account)
    contact = create(:contact, account: account)
    _callout_participation = create_callout_participation(
      account: account,
      callout: callout,
      contact: contact
    )
    _other_contact = create(:contact, account: account)

    get(
      api_callout_contacts_path(callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(contact.id)
  end

  it "can preview contacts to be populated for a callout population" do
    contact = create(:contact, account: account, metadata: { "foo" => "bar" })
    _other_contact = create(:contact, account: account)

    callout_population = create(
      :callout_population,
      account: account,
      contact_filter_params: { metadata: contact.metadata }
    )

    get(
      api_batch_operation_preview_contacts_path(callout_population),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(contact.id)
  end

  it "can list all contacts populated by a callout population" do
    callout_population = create(:callout_population, account: account)
    callout_participation = create_callout_participation(
      account: account,
      callout_population: callout_population
    )
    _other_callout_participation = create_callout_participation(account: account)

    get(
      api_batch_operation_contacts_path(callout_population),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(callout_participation.contact_id)
  end

  it "can preview all contacts to be called by a phone call create batch operation" do
    callout_participation = create_callout_participation(
      account: account, metadata: { "foo" => "bar" }
    )
    _other_callout_participation = create_callout_participation(account: account)
    batch_operation = create(
      :phone_call_create_batch_operation,
      account: account,
      callout_participation_filter_params: { metadata: callout_participation.metadata }
    )

    get(
      api_batch_operation_preview_contacts_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(callout_participation.contact_id)
  end

  it "can list all contacts to be called by a phone call create batch operation" do
    batch_operation = create(:phone_call_create_batch_operation, account: account)
    phone_call = create_phone_call(
      account: account,
      create_batch_operation: batch_operation
    )
    _other_contact = create(:contact, account: account)

    get(
      api_batch_operation_contacts_path(batch_operation),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(phone_call.contact_id)
  end

  it "can create a contact" do
    request_body = {
      msisdn: generate(:somali_msisdn),
      metadata: {
        "foo" => "bar"
      }
    }

    post(
      api_contacts_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    created_contact = account.contacts.find(parsed_response.fetch("id"))
    expect(created_contact.msisdn).to include(request_body.fetch(:msisdn))
    expect(created_contact.metadata).to eq(request_body.fetch(:metadata))
  end

  it "does not create invalid contacts" do
    post(
      api_contacts_path,
      params: {},
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  it "can fetch a contact" do
    contact = create(:contact, account: account)

    get(
      api_contact_path(contact),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_response = JSON.parse(response.body)
    expect(
      account.contacts.find(parsed_response.fetch("id"))
    ).to eq(contact)
  end

  it "can update a contact" do
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

    patch(
      api_contact_path(contact),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    contact.reload
    expect(contact.metadata).to eq(request_body.fetch(:metadata))
  end

  it "does not update a contact with invalid data" do
    contact = create(:contact, account: account)
    request_body = { msisdn: "1234" }

    patch(
      api_contact_path(contact),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  it "can create contact data" do
    request_body = {
      msisdn: generate(:somali_msisdn),
      metadata: {
        "foo" => "bar"
      }
    }

    post(
      api_contact_data_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    created_contact = account.contacts.find(parsed_response.fetch("id"))
    expect(created_contact.msisdn).to include(request_body.fetch(:msisdn))
    expect(created_contact.metadata).to eq(request_body.fetch(:metadata))
  end

  it "can update contact data" do
    msisdn = generate(:somali_msisdn)
    contact = create(:contact, account: account, msisdn: msisdn, metadata: { "bar" => "foo" })
    request_body = { msisdn: msisdn, metadata_merge_mode: "replace", metadata: { "foo" => "bar" } }

    post(
      api_contact_data_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    contact.reload
    expect(parsed_response.fetch("id")).to eq(contact.id)
    expect(contact.metadata).to eq(request_body.fetch(:metadata))
  end

  it "can delete a contact" do
    contact = create(:contact, account: account)

    delete(
      api_contact_path(contact),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(Contact.find_by_id(contact.id)).to eq(nil)
  end

  it "cannot delete a contact which has phone calls" do
    contact = create(:contact, account: account)
    _phone_call = create_phone_call(account: account, contact: contact)

    delete(
      api_contact_path(contact),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
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
