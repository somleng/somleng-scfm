module Somleng
  class Client
    attr_reader :provider, :somleng_rest_client

    delegate :api, to: :somleng_rest_client

    def initialize(provider:, somleng_rest_client: nil)
      @provider = provider
      @somleng_rest_client = somleng_rest_client || default_rest_client
    end

    def default_rest_client
      client = Somleng::REST::Client.new(provider.account_sid, provider.auth_token)
      client.api_host = provider.api_host
      client.api_base_url = provider.api_base_url
      client
    end
  end
end
