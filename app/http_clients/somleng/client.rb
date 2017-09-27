class Somleng::Client
  attr_accessor :somleng_rest_client

  delegate :api, :to => :somleng_rest_client

  def initialize(options = {})
    self.somleng_rest_client = options[:somleng_rest_client]
  end

  def somleng_rest_client
    @somleng_rest_client ||= Somleng::REST::Client.new(
      ENV["SOMLENG_ACCOUNT_SID"],
      ENV["SOMLENG_AUTH_TOKEN"]
    )
  end
end
