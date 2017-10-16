class UpdateCallsTask < ApplicationTask
  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :update_calls_task_max_calls_to_fetch => nil
    }

    def self.default_env_vars(task_name)
      super.merge(DEFAULT_ENV_VARS).merge(default_somleng_env_vars(task_name))
    end
  end

  def run!
    PhoneCall.waiting_for_completion.with_remote_call_id.not_recently_created.limit(num_calls_to_fetch).find_each do |phone_call|
      begin
        mark_as_fetching_status!(phone_call)
        fetch_remote!(phone_call.reload)
      rescue ActiveRecord::StaleObjectError
      ensure
        phone_call.finish_fetching_status!
      end
    end
  end

  private

  def mark_as_fetching_status!(phone_call)
    phone_call.fetch_status!
  end

  def fetch_remote!(phone_call)
    response = somleng_client.api.calls(phone_call.remote_call_id).fetch
    phone_call.remote_status = response.status
    phone_call.remote_response = response.instance_variable_get(:@properties).compact
    phone_call.complete!
  end

  def somleng_client
    @somleng_client ||= Somleng::Client.new
  end

  def num_calls_to_fetch
    max_calls_to_fetch
  end

  def max_calls_to_fetch
    ENV["UPDATE_CALLS_TASK_MAX_CALLS_TO_FETCH"].to_i if ENV["UPDATE_CALLS_TASK_MAX_CALLS_TO_FETCH"].present?
  end
end
