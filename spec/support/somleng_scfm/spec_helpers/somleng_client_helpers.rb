module SomlengScfm::SpecHelpers::SomlengClientHelpers
  def somleng_client_rest_api_host
    @somleng_client_rest_api_host ||= "api.twilio.com"
  end

  def somleng_client_rest_api_base_url
    @somleng_client_rest_api_base_url ||= "https://api.twilio.com"
  end

  def somleng_account_sid
    @somleng_account_sid ||= "account-sid"
  end

  def somleng_auth_token
    @somleng_auth_token ||= "auth-token"
  end

  def env
    somleng_client_env = {
      "PLATFORM_PROVIDER" => "somleng",
      "SOMLENG_CLIENT_REST_API_HOST" => somleng_client_rest_api_host,
      "SOMLENG_CLIENT_REST_API_BASE_URL" => somleng_client_rest_api_base_url,
      "SOMLENG_ACCOUNT_SID" => somleng_account_sid,
      "SOMLENG_AUTH_TOKEN" => somleng_auth_token
    }
    merge_with = defined?(super) ? super : {}
    merge_with.merge(somleng_client_env)
  end

  def asserted_remote_api_endpoint(path)
    @asserted_remote_api_endpoint ||= "#{somleng_client_rest_api_base_url}/2010-04-01/Accounts/#{somleng_account_sid}/#{path}.json"
  end

  def asserted_remote_response_status
    @asserted_remote_response_status ||= 200
  end

  def asserted_remote_response
    @asserted_remote_response ||= {
      :status => asserted_remote_response_status,
      :body => asserted_remote_response_body
    }
  end

  def client_requests
    WebMock.requests
  end

  def client_request_body(request)
    WebMock::Util::QueryMapper.query_to_values(request.body)
  end

  def assert_somleng_client_request!
    authorization = Base64.decode64(client_requests.last.headers["Authorization"].sub(/^Basic\s/, ""))
    expect(authorization).to eq("#{somleng_account_sid}:#{somleng_auth_token}")
  end
end
