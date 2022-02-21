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

    example "Filtering, Sorting and Pagination" do
      explanation <<~HEREDOC
        All index requests can be filtered and sorted by using the `q` and `sort` parameters.
        Responses are paginated. The maxiumum number of items displayed for a single request is 25.
        This can be verified by the `Per-Page` response header. The actual number of items will appear in the `Total` header.
        If there are more than 25 items then you'll see a `Link` header with links to the
        `first`, `last`, `next` and `previous` pages.
        The links are formatted according to [RFC-8288](https://tools.ietf.org/html/rfc8288).
      HEREDOC

      filtered_contacts = create_list(
        :contact,
        26,
        account: account,
        metadata: {
          "gender" => "f",
          "date_of_birth" => "2022-01-15"
        }
      )

      create(
        :contact,
        account: account,
        metadata: {
          "gender" => "f"
        },
        created_at: 2.days.ago
      )

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => {
            "gender" => "f",
            "date_of_birth.date.gt" => "2022-01-01",
            "date_of_birth.date.lt" => "2022-02-01"
          },
          "created_at_after" => Date.yesterday
        },
        sort: "-id,created_at"
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(25)
      expect(response_headers).to include(
        "Per-Page" => "25",
        "Total" => "26"
      )
      expect(response_headers).to have_key("Link")
      expect(parsed_body.first.fetch("id")).to eq(filtered_contacts.last.id)
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
      explanation <<~HEREDOC
        Metadata is useful for storing additional,
        structured information on an object.
        As an example, you could store the contact's name and gender on the `Contact` object.
      HEREDOC

      contact = create(
        :contact,
        account: account,
        metadata: {
          "gender" => "f"
        }
      )

      request_body = {
        metadata: {
          "name" => "Kate"
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
