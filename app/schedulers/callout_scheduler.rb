class CalloutScheduler < ApplicationScheduler
  DEFAULT_MAX_PHONE_CALLS_TO_SCHEDULE = 1

  def run!
    callout.phone_numbers.no_phone_calls_or_last_attempt(:failed).limit(max_phone_calls_to_schedule).find_each do |phone_number|
      phone_call = schedule_phone_call!(phone_number)
      queue_phone_call!(phone_call)
    end
  end

  private

  def schedule_phone_call!(phone_number)
    phone_call = phone_number.phone_calls.new
    phone_call.schedule!
    phone_call
  end

  def queue_phone_call!(phone_call)
    begin
      response = queue_remote_call!(phone_call.phone_number)
      phone_call.remote_call_id = response.sid
    rescue Twilio::REST::RestError => e
      phone_call.remote_error_message = e.message
    end

    phone_call.queue!
  end

  def queue_remote_call!(phone_number)
    somleng_rest_client.api.account.calls.create(
      {
        :to => phone_number.msisdn
      }.merge(default_call_params)
    )
  end

  def max_phone_calls_to_schedule
    (ENV["CALLOUT_SCHEDULER_MAX_PHONE_CALLS_TO_SCHEDULE"] || DEFAULT_MAX_PHONE_CALLS_TO_SCHEDULE).to_i
  end

  def callout
    @callout ||= find_callout
  end

  def find_callout
    Callout.first!
  end

  def somleng_rest_client
    @somleng_rest_client ||= Somleng::REST::Client.new(
      ENV["SOMLENG_ACCOUNT_SID"],
      ENV["SOMLENG_AUTH_TOKEN"]
    )
  end

  def default_call_params
    @default_call_params ||= JSON.parse(ENV["CALLOUT_SCHEDULER_DEFAULT_CALL_PARAMS"] || "{}").symbolize_keys
  end
end
