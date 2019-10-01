module RequestSpecHelpers
  def set_authorization_header(access_token:)
    authentication :basic, "Bearer #{access_token.token}"
  end
end

RSpec.configure do |config|
  config.include(RequestSpecHelpers, type: :request)
end
