module Somleng
  class PlatformProvider
    attr_reader :account_sid,
                :auth_token,
                :api_host,
                :api_base_url

    def initialize(account_sid:, auth_token:, api_host:, api_base_url:)
      @account_sid = account_sid
      @auth_token = auth_token
      @api_host = api_host
      @api_base_url = api_base_url
    end
  end
end
