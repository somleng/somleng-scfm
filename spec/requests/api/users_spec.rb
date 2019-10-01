require "rails_helper"

RSpec.resource "Users" do
  header("Content-Type", "application/json")

  get "/api/users" do
    example "List all Users" do
      filtered_user = create(
        :user,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      create(:user, account: account)
      create(:user)

      set_authorization_header(access_token: access_token)
      do_request(
        q: { "metadata" => { "foo" => "bar" } }
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_user.id)
    end
  end

  get "/api/accounts/:account_id/users" do
    example "List all Users under an account", document: false do
      super_admin_account = create(:account, :super_admin)
      access_token = create_access_token(resource_owner: super_admin_account)
      user_account = create(:account)
      user = create(:user, account: user_account)
      _other_user = create(:user, account: super_admin_account)

      set_authorization_header(access_token: access_token)
      do_request(account_id: user_account.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(user.id)
    end
  end

  post "/api/users" do
    parameter(
      :email,
      "The email address of the user",
      required: true
    )

    parameter(
      :password,
      "The initial password of the user. The user can change their password when they log in.",
      required: true
    )

    example "Create a User" do
      request_body = build_request_body

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(201)
      created_user = User.last
      expect(created_user.account).to eq(account)
      expect(created_user.email).to eq(request_body.fetch(:email))
      expect(created_user.metadata).to eq(request_body.fetch(:metadata))
    end

    example "Create a User as a super admin", document: false do
      super_admin_account = create(:account, :super_admin)
      access_token = create_access_token(resource_owner: super_admin_account)
      user_account = create(:account)
      request_body = build_request_body(account_id: user_account.id)

      set_authorization_header(access_token: access_token)
      do_request(request_body)

      expect(response_status).to eq(201)
      created_user = User.last
      expect(created_user.account).to eq(user_account)
    end
  end

  get "/api/users/:id" do
    example "Retrieve a User" do
      user = create(:user, account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: user.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.users.find(parsed_response.fetch("id"))
      ).to eq(user)
    end
  end

  patch "/api/users/:id" do
    example "Update a User" do
      user = create(
        :user,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )

      request_body = { metadata: { "bar" => "foo" }, metadata_merge_mode: "replace" }

      set_authorization_header(access_token: access_token)
      do_request(id: user.id, **request_body)

      expect(response_status).to eq(204)
      user.reload
      expect(user.metadata).to eq(request_body.fetch(:metadata))
    end
  end

  delete "/api/users/:id" do
    example "Delete a User" do
      user = create(:user, account: account)

      set_authorization_header(access_token: access_token)
      do_request(id: user.id)

      expect(response_status).to eq(204)
      expect(User.find_by_id(user.id)).to eq(nil)
    end
  end

  post "/api/users/:user_id/user_events" do
    parameter(
      :event,
      "Only `invite` is supported at this time",
      required: true
    )

    example "Create a User Event" do
      account = create(:account)
      access_token = create_access_token(resource_owner: account)
      user = create(:user, account: account)

      set_authorization_header(access_token: access_token)
      do_request(user_id: user.id, event: "invite")

      expect(response_status).to eq(201)
      expect(response_headers.fetch("Location")).to eq(api_user_path(user))
      user.reload
      expect(user.invitation_sent_at).to be_present
    end
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
