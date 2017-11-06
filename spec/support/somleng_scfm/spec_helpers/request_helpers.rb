module SomlengScfm::SpecHelpers::RequestHelpers
  def env
    super.merge(
      "HTTP_BASIC_AUTH_USER" => http_basic_auth_user,
      "HTTP_BASIC_AUTH_PASSWORD" => http_basic_auth_password,
    )
  end

  def do_request(method, path, body = {}, headers = {}, options = {})
    public_send(method, path, {:params => body, :headers => authorization_headers.merge(headers)}.merge(options))
  end

  def assert_index!
    expect(response.code).to eq("200")
    expect(response.headers["Per-Page"]).to eq("25")
  end

  def authorization_headers
    authorization_user ? {"HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(authorization_user, authorization_password)} : {}
  end

  def http_basic_auth_user
    "user"
  end

  def http_basic_auth_password
    "secret"
  end

  def authorization_user
    http_basic_auth_user
  end

  def authorization_password
    http_basic_auth_password
  end
end
