class PhoneCallUpdaterTask < ApplicationTask
  def run!
    PhoneCall.queued.with_remote_call_id.not_recently_created.find_each do |phone_call|
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
end
