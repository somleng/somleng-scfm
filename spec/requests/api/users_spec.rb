require "rails_helper"

RSpec.describe "Users" do
  it "can list all users" do
    filtered_user = create(
      :user,
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )
    create(:user, account: account)
    create(:user)

    get(
      api_users_path(q: { "metadata" => { "foo" => "bar" } }),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(filtered_user.id)
  end

  it "super admin can list all users under an account" do
    super_admin_account = create(:account, :super_admin)
    access_token = create_access_token(resource_owner: super_admin_account)
    user_account = create(:account)
    user = create(:user, account: user_account)
    _other_user = create(:user, account: super_admin_account)

    get(
      api_account_users_path(user_account),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(user.id)
  end

  it "can create a user" do
    request_body = build_request_body

    post(
      api_users_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    created_user = User.last
    expect(created_user.account).to eq(account)
    expect(created_user.email).to eq(request_body.fetch(:email))
    expect(created_user.metadata).to eq(request_body.fetch(:metadata))
  end

  it "super admin can create a user" do
    super_admin_account = create(:account, :super_admin)
    access_token = create_access_token(resource_owner: super_admin_account)
    user_account = create(:account)
    request_body = build_request_body(account_id: user_account.id)

    post(
      api_users_path,
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("201")
    created_user = User.last
    expect(created_user.account).to eq(user_account)
  end

  it "can fetch a user" do
    user = create(:user, account: account)

    get(
      api_user_path(user),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_response = JSON.parse(response.body)
    expect(
      account.users.find(parsed_response.fetch("id"))
    ).to eq(user)
  end

  it "can update a user" do
    user = create(
      :user,
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )

    request_body = { metadata: { "bar" => "foo" }, metadata_merge_mode: "replace" }

    patch(
      api_user_path(user),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    user.reload
    expect(user.metadata).to eq(request_body.fetch(:metadata))
  end

  it "can delete a user" do
    user = create(:user, account: account)

    delete(
      api_user_path(user),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(User.find_by_id(user.id)).to eq(nil)
  end

  def build_request_body(options = {})
    {
      email: options.delete(:email) || generate(:email),
      password: options.delete(:password) || "secret123",
      metadata: options.delete(:metadata) || { "foo" => "bar" }
    }.merge(options)
  end

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[users_read users_write],
      **options
    )
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }
end
