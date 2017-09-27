class PhoneCallUpdaterTask < ApplicationTask
  def run!
    PhoneCall.queued.with_remote_call_id.not_recently_created.limit(max_calls_to_fetch).find_each do |phone_call|
      update_from_remote_call!(phone_call)
    end
  end

  private

  def update_from_remote_call!(phone_call)
    response = somleng_client.api.calls(phone_call.remote_call_id).fetch
    phone_call.remote_status = response.status
    phone_call.remote_response = response.instance_variable_get(:@properties).compact
    phone_call.complete!
  end

  def max_calls_to_fetch
    ENV["PHONE_CALL_UPDATER_TASK_MAX_CALLS_TO_FETCH"].to_i if ENV["PHONE_CALL_UPDATER_TASK_MAX_CALLS_TO_FETCH"]
  end
end
