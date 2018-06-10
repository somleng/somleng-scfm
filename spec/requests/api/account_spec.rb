require "rails_helper"

RSpec.describe "Account" do
  it "can fetch the account" do
    account = create(:account)
    access_token = create_access_token(resource_owner: account)

    get(
      api_current_account_path,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
  end

  it "can update the account" do
    account = create(
      :account,
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

    access_token = create_access_token(resource_owner: account)

    patch(
      api_current_account_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(account.reload.metadata).to eq(request_body.fetch(:metadata))
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[accounts_read accounts_write], **options
    )
  end
end
