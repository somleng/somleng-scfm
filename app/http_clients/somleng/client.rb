class Somleng::Client
  attr_accessor :somleng_rest_client,
                :provider

  delegate :api, :to => :somleng_rest_client

  def initialize(provider:, somleng_rest_client: nil)
    self.provider = provider
    self.somleng_rest_client = somleng_rest_client
  end

  def somleng_rest_client
    @somleng_rest_client ||= begin
      client = Somleng::REST::Client.new(provider.account_sid, provider.auth_token)
      client.api_host = provider.api_host
      client.api_base_url = provider.api_base_url
      client
    end
  end
end
