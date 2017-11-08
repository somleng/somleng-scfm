class CalloutsTask < ApplicationTask
  AVAILABLE_ACTIONS = ["start", "stop", "pause", "resume"]

  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :rails_env => "production",
      :callouts_task_action => "stop|pause|resume"
    }

    def self.rake_tasks
      super + [:populate!, :statistics]
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
    stats = CalloutStatistics.new(:callout => callout).as_json
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

  def action
    ENV["CALLOUTS_TASK_ACTION"] && ENV["CALLOUTS_TASK_ACTION"].to_s.sub(/!$/, "")
  end
end
