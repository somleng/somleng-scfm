module RequestSpecHelpers
  def build_authorization_headers(access_token:)
    { "HTTP_AUTHORIZATION" => encode_credentials(access_token: access_token) }
  end

  def encode_credentials(access_token:)
    ActionController::HttpAuthentication::Basic.encode_credentials(access_token.token, nil)
  end
end

RSpec.configure do |config|
  config.include(RequestSpecHelpers, type: :request)
  config.include(RequestSpecHelpers, type: :job)
end
