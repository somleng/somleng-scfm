require "rails_helper"

RSpec.resource "Shared API Features" do
  header("Content-Type", "application/json")

  get "/api/contacts" do
    parameter(
      :q,
      "A filter in which to filter resources. You can always filter by `metadata`, `created_at` and `updated_at`. Additional filters are available different resources"
    )

    parameter(
      :sort,
      "A comma separated list of sort columns. For example to sort by `id` in descending order, then by `created_at` in ascending order, specify `sort: -id,created_at`"
    )

    example "Filtering and Sorting" do
      _matching_contact = create(:contact, account: account, metadata: { "foo" => "bar" })
      filtered_contact = create(:contact, account: account, metadata: { "foo" => "bar" })

      create(:contact, account: account, metadata: { "foo" => "bar" }, created_at: 2.days.ago)
      create(:contact)

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" },
          "created_at_after" => 1.day.ago
        },
        sort: "-id,created_at"
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(2)
      expect(parsed_body.first.fetch("id")).to eq(filtered_contact.id)
    end
  end

  patch "/api/contacts/:id" do
    parameter(
      :metadata,
      "Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format."
    )

    parameter(
      :metadata_merge_mode,
      "One of: `merge` (default), `replace` or `deep_merge`. `merge` merges the new metadata with the existing metadata. `replace` replaces the existing metadata with the new metadata. `deep_merge` deep merges the existing metadata with the new metadata.",
    )

    example "Metadata" do
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
  end

  let(:account) { create(:account) }
  let(:access_token) { create(:access_token, resource_owner: account, permissions: %i[contacts_read contacts_write]) }
end
