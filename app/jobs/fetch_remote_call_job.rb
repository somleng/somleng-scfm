class FetchRemoteCallJob < ApplicationJob
  attr_accessor :phone_call_id

  def perform(phone_call_id)
    self.phone_call_id = phone_call_id
    begin
      response = fetch_remote_call!
      phone_call.remote_response = response.instance_variable_get(:@properties).compact
      phone_call.new_remote_status = phone_call.remote_status = response.status
    rescue Twilio::REST::RestError => e
      phone_call.remote_error_message = e.message
    end

    phone_call.complete!
  end

  private

  def phone_call
    @phone_call ||= PhoneCall.find(phone_call_id)
  end

  def fetch_remote_call!
    somleng_client.api.calls(phone_call.remote_call_id).fetch
  end

  def somleng_client
    @somleng_client ||= Somleng::Client.new
  end
end
