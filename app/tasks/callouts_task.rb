class CalloutsTask < ApplicationTask
  AVAILABLE_ACTIONS = ["start", "stop", "pause", "resume"]

  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :rails_env => "production",
      :callouts_task_action => "stop|pause|resume"
    }

    def self.install_cron?(task_name)
      task_name == :run!
    end

    def self.default_env_vars(task_name)
      super.merge(DEFAULT_ENV_VARS)
    end
  end

  def run!
    AVAILABLE_ACTIONS.include?(action) ? callout.public_send("#{action}!") : raise(
      ArgumentError,
      "Action: '#{action}' not recognized. Please specify one of #{AVAILABLE_ACTIONS} in ENV['CALLOUTS_TASK_ACTION']"
    )
  end

  def callout
    @callout ||= (!ENV["CALLOUTS_TASK_CALLOUT_ID"].present? && Callout.count == 1 && Callout.first!) || Callout.find(ENV["CALLOUTS_TASK_CALLOUT_ID"])
  end

  private

  def action
    ENV["CALLOUTS_TASK_ACTION"] && ENV["CALLOUTS_TASK_ACTION"].to_s.sub(/!$/, "")
  end
end
