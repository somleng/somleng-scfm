require "rails_helper"

RSpec.describe "Access Tokens" do
  let(:access_token) { create_access_token }
  let(:account) { access_token.resource_owner }

  it "can list all access tokens" do
    filtered_access_token = create(
      :access_token,
      resource_owner: account,
      metadata: {
        "foo" => "bar"
      }
    )
    create(:access_token)

    get(
      api_access_tokens_path(
        q: {
          "metadata" => {
            "foo" => "bar"
          }
        }
      ),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(filtered_access_token.id)
  end

  it "can list all access tokens under an account" do
    super_admin_account = create(:account, :super_admin)
    super_admin_access_token = create_access_token(resource_owner: super_admin_account)

    get(
      api_account_access_tokens_path(account),
      headers: build_authorization_headers(access_token: super_admin_access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(access_token.id)
  end

  it "can create an access token" do
    request_body = {
      metadata: {
        "foo" => "bar"
      },
      permissions: [
        :contacts_write
      ]
    }

    post(
      api_access_tokens_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    expect(parsed_response.fetch("metadata")).to eq(request_body.fetch(:metadata))
    created_access_token = AccessToken.find(parsed_response.fetch("id"))
    expect(created_access_token.resource_owner).to eq(account)
    expect(created_access_token.created_by).to eq(account)
    expect(created_access_token.permissions).to match_array(request_body.fetch(:permissions))
  end

  it "can create an access token as a super admin" do
    super_admin_account = create(:account, :super_admin)
    access_token = create_access_token(resource_owner: super_admin_account)
    account_for_access_token = create(:account)

    request_body = {
      account_id: account_for_access_token.id
    }

    post(
      api_access_tokens_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    created_access_token = AccessToken.find(parsed_response.fetch("id"))
    expect(created_access_token.resource_owner).to eq(account_for_access_token)
    expect(created_access_token.created_by).to eq(super_admin_account)
  end

  it "can fetch an access token" do
    get(
      api_access_token_path(access_token),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    expect(response.body).to eq(access_token.to_json)
  end

  it "can update an access token" do
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

    patch(
      api_access_token_path(access_token),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(access_token.reload.metadata).to eq(request_body.fetch(:metadata))
  end

  it "can delete an access token" do
    delete(
      api_access_token_path(access_token),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(AccessToken.find_by_id(access_token.id)).to eq(nil)
  end

  it "cannot delete an access token created by another account" do
    other_account = create(:account)
    access_token = create_access_token(created_by: other_account)

    delete(
      api_access_token_path(access_token),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  def create_access_token(**options)
    create(:access_token, permissions: %i[access_tokens_read access_tokens_write], **options)
  end
end
