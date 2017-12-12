require_relative "../spec_helpers"

module SomlengScfm::SpecHelpers::RequestHelpers
  def do_request(method, path, body = {}, headers = {}, options = {})
    public_send(method, path, {:params => body, :headers => authorization_headers.merge(headers)}.merge(options))
  end

  def assert_index!
    expect(response.code).to eq("200")
    expect(response.headers["Per-Page"]).to eq("25")
  end

  def build_authorization_headers(user, password)
    user ? {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(
        user, password
      )
    } : {}
  end

  def authorization_headers
    build_authorization_headers(access_token, nil)
  end

  def account
    @account ||= create(:account, :with_access_token)
  end

  def access_token
    account.access_token.token
  end
end
