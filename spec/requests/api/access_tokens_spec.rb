require "rails_helper"

RSpec.resource "Access Tokens" do
  let(:access_token) { create_access_token }
  let(:account) { access_token.resource_owner }

  header("Content-Type", "application/json")

  get "/api/access_tokens" do
    parameter(
      :q,
      "A filter in which to filter resources"
    )

    example "List all Access Tokens" do
      filtered_access_token = create(
        :access_token,
        resource_owner: account,
        metadata: {
          "foo" => "bar"
        }
      )
      create(:access_token)

      set_authorization_header(access_token: access_token)
      do_request(
        q: {
          "metadata" => {
            "foo" => "bar"
          }
        }
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_access_token.id)
    end
  end

  get "/api/accounts/:account_id/access_tokens" do
    example "List all Access Tokens under another account", document: false do
      super_admin_account = create(:account, :super_admin)
      super_admin_access_token = create_access_token(resource_owner: super_admin_account)

      set_authorization_header(access_token: super_admin_access_token)
      do_request(account_id: account.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(access_token.id)
    end
  end

  post "/api/access_tokens" do
    parameter(
      :permissions,
      "An array of permissions for the access token"
    )
    parameter(
      :metadata,
      "Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format."
    )

    example "Create an Access Token" do
      request_body = {
        metadata: {
          "foo" => "bar"
        },
        permissions: [
          :contacts_write
        ]
      }

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      expect(parsed_response.fetch("metadata")).to eq(request_body.fetch(:metadata))
      created_access_token = AccessToken.find(parsed_response.fetch("id"))
      expect(created_access_token.resource_owner).to eq(account)
      expect(created_access_token.created_by).to eq(account)
      expect(created_access_token.permissions).to match_array(request_body.fetch(:permissions))
    end

    example "Create an Access Token for another account" do
      super_admin_account = create(:account, :super_admin)
      access_token = create_access_token(resource_owner: super_admin_account)
      account_for_access_token = create(:account)

      request_body = {
        account_id: account_for_access_token.id
      }

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_access_token = AccessToken.find(parsed_response.fetch("id"))
      expect(created_access_token.resource_owner).to eq(account_for_access_token)
      expect(created_access_token.created_by).to eq(super_admin_account)
    end
  end

  get "/api/access_tokens/:id" do
    example "Retrieve an Access Token" do
      set_authorization_header(access_token: access_token)
      do_request(id: access_token.id)

      expect(response_status).to eq(200)
      expect(response_body).to eq(access_token.to_json)
    end
  end

  patch "api/access_tokens/:id" do
    example "Update an Access Token" do
      access_token = create_access_token(
        metadata: {
          "bar" => "baz"
        }
      )
      request_body = {
        metadata: {
          "foo" => "bar"
        },
        metadata_merge_mode: "replace"
      }

      set_authorization_header(access_token: access_token)
      do_request(id: access_token.id, **request_body)

      expect(response_status).to eq(204)
      expect(access_token.reload.metadata).to eq(request_body.fetch(:metadata))
    end
  end

  delete "/api/access_tokens/:id" do
    example "Delete an Access Token" do
      set_authorization_header(access_token: access_token)
      do_request(id: access_token.id)

      expect(response_status).to eq(204)
      expect(AccessToken.find_by_id(access_token.id)).to eq(nil)
    end

    example "Delete an Access Token from another account", document: false do
      other_account = create(:account)
      access_token = create_access_token(created_by: other_account)

      set_authorization_header(access_token: access_token)
      do_request(id: access_token.id)

      expect(response_status).to eq(422)
    end
  end

  def create_access_token(**options)
    create(:access_token, permissions: %i[access_tokens_read access_tokens_write], **options)
  end
end
