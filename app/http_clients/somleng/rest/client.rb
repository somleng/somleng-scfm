class Somleng::REST::Client < Twilio::REST::Client
  attr_accessor :api_host, :api_base_url

  def api
    @api ||= Somleng::REST::Api.new(self)
  end
end
