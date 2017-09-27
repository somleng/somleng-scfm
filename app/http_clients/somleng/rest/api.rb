class Somleng::REST::Api < Twilio::REST::Api
  def initialize(twilio)
    super
    @host = custom_api_host if custom_api_host
    @base_url = custom_base_url if custom_base_url
  end

  def custom_api_host
    ENV["SOMLENG_CLIENT_REST_API_HOST"]
  end

  def custom_base_url
    ENV["SOMLENG_CLIENT_REST_API_BASE_URL"]
  end
end
