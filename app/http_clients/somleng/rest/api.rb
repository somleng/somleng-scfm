class Somleng::REST::Api < Twilio::REST::Api
  def initialize(twilio)
    super
    @host = twilio.api_host if twilio.api_host
    @base_url = twilio.api_base_url if twilio.api_base_url
  end
end
