class Somleng::REST::Client < Twilio::REST::Client
  def api
    @api ||= Somleng::REST::Api.new(self)
  end
end
