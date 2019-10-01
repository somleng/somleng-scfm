require "rails_helper"

RSpec.resource "Account Details" do
  header("Content-Type", "application/json")

  get "/api/account" do
    example "Retrieve Account Details" do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)

      set_authorization_header(access_token: access_token)
      do_request

      expect(response_status).to eq(200)
    end
  end

  patch "/api/account" do
    example "Update Account Details" do
      account = create(
        :account,
        metadata: {
          "bar" => "baz"
        }
      )
      access_token = create_access_token(resource_owner: account)
      request_body = {
        metadata: {
          "foo" => "bar"
        },
        metadata_merge_mode: "replace"
      }

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(204)
      expect(account.reload.metadata).to eq(request_body.fetch(:metadata))
    end
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[accounts_read accounts_write], **options
    )
  end
end
