class Somleng::Client
  DEFAULT_PLATFORM_PROVIDER = "TWILIO"

  attr_accessor :somleng_rest_client,
                :platform_provider

  delegate :api, :to => :somleng_rest_client

  def initialize(options = {})
    self.somleng_rest_client = options[:somleng_rest_client]
    self.platform_provider = options[:platform_provider]
  end

  def somleng_rest_client
    @somleng_rest_client ||= Somleng::REST::Client.new(
      resolve_configuration("ACCOUNT_SID"),
      resolve_configuration("AUTH_TOKEN")
    )
  end

  def platform_provider
    @platform_provider ||= ENV["PLATFORM_PROVIDER"] || DEFAULT_PLATFORM_PROVIDER
  end

  private

  def resolve_configuration(key)
    ENV[[platform_provider, key].join("_").upcase]
  end
end
