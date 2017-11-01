class CalloutsTask < ApplicationTask
  AVAILABLE_ACTIONS = ["start", "stop", "pause", "resume"]

  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :rails_env => "production",
      :callouts_task_action => "stop|pause|resume"
    }

    def self.rake_tasks
      super + [:create!, :populate!, :statistics]
    end

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

  def create!
    new_callout = Callout.create!(
      :metadata => default_create_metadata.merge(create_metadata)
    )
    puts(new_callout.id)
    new_callout
  end

  def populate!
    population = contacts_to_populate_with.count
    contacts_to_populate_with.find_each.with_index do |contact, index|
      CalloutParticipation.create(
        :callout => callout,
        :contact => contact,
        :msisdn => contact.msisdn,
        :metadata => default_populate_metadata.merge(populate_metadata(contact))
      )

      puts("Populated callout with #{index + 1}/#{population} phone numbers") if (index % 1000) == 0
    end
  end

  def statistics
    stats = {
      :callout_status => callout.status.titleize,
      :callout_participations => callout.callout_participations.count,
      :callout_participations_still_to_call => callout.callout_participations.remaining.count,
      :callout_participations_completed => callout.callout_participations.completed.count,
      :calls_completed => callout.phone_calls.completed.count,
      :calls_initialized => callout.phone_calls.created.count,
      :calls_scheduling => callout.phone_calls.scheduling.count,
      :calls_fetching_status => callout.phone_calls.fetching_status.count,
      :calls_waiting_for_completion => callout.phone_calls.waiting_for_completion.count,
      :calls_queued => callout.phone_calls.queued.count,
      :calls_in_progress => callout.phone_calls.in_progress.count,
      :calls_errored => callout.phone_calls.errored.count,
      :calls_failed => callout.phone_calls.failed.count,
      :calls_busy => callout.phone_calls.busy.count,
      :calls_not_answered => callout.phone_calls.not_answered.count,
      :calls_canceled => callout.phone_calls.canceled.count
    }

    padding = stats.keys.map { |name| name.to_s.length }.max + 1
    puts(stats.map { |name, value| name.to_s.titleize + ":" + (" " * (padding - name.to_s.length)) + value.to_s }.join("\n"))
  end

  def callout
    @callout ||= (!ENV["CALLOUTS_TASK_CALLOUT_ID"].present? && Callout.count == 1 && Callout.first!) || Callout.find(ENV["CALLOUTS_TASK_CALLOUT_ID"])
  end

  private

  def contacts_to_populate_with
    Contact.all
  end

  def populate_metadata(contact)
    {}
  end

  def default_populate_metadata
    JSON.parse(ENV["CALLOUTS_TASK_POPULATE_METADATA"] || "{}")
  end

  def create_metadata
    {}
  end

  def default_create_metadata
    JSON.parse(ENV["CALLOUTS_TASK_CREATE_METADATA"] || "{}")
  end

  def action
    ENV["CALLOUTS_TASK_ACTION"] && ENV["CALLOUTS_TASK_ACTION"].to_s.sub(/!$/, "")
  end
end
