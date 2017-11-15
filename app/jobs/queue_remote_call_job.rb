class QueueRemoteCallJob < ApplicationJob
  attr_accessor :phone_call_id

  def perform(phone_call_id)
    self.phone_call_id = phone_call_id
    begin
      response = queue_remote_call!
      phone_call.remote_queue_response = response.instance_variable_get(:@properties).compact
      phone_call.remote_status = response.status
      phone_call.remote_call_id = response.sid
      phone_call.remote_direction = response.direction
    rescue Twilio::REST::RestError => e
      phone_call.remote_error_message = e.message
    end

    phone_call.queue_remote!
  end

  private

  def phone_call
    @phone_call ||= PhoneCall.find(phone_call_id)
  end

  def queue_remote_call!
    somleng_client.api.account.calls.create(remote_request_params)
  end

  def remote_request_params
    phone_call.remote_request_params.merge("to" => phone_call.msisdn).symbolize_keys
  end

  def somleng_client
    @somleng_client ||= Somleng::Client.new
  end
end
