module RequestSpecHelpers
  def build_authorization_headers(access_token:)
    {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(
        access_token.token, nil
      )
    }
  end
end

RSpec.configure do |config|
  config.include(RequestSpecHelpers, type: :request)
end
