class EnqueueCallsTask < ApplicationTask
  DEFAULT_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE = 1
  DEFAULT_ENQUEUE_STRATEGY = "optimistic"
  ENQUEUE_STRATEGIES = [DEFAULT_ENQUEUE_STRATEGY, "pessimistic"]
  DEFAULT_MAX_CALLS_PER_PERIOD_HOURS = 24

  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :enqueue_calls_task_max_calls_to_enqueue => "30",
      :enqueue_calls_task_enqueue_strategy => "optimistic",
      :enqueue_calls_task_pessimistic_min_calls_to_enqueue => "1"
    }

    def self.default_env_vars(task_name)
      super.merge(DEFAULT_ENV_VARS).merge(default_somleng_env_vars(task_name))
    end
  end

  def run!
    callout_participations_to_call.limit(max_num_calls_to_enqueue).find_each do |callout_participation|
      phone_call = schedule_phone_call!(callout_participation)
      enqueue_phone_call!(phone_call)
    end
  end

  def max_num_calls_to_enqueue
    [
      send("#{enqueue_strategy}_max_num_calls_to_enqueue"),
      max_calls_per_period && calls_remaining_in_period
    ].compact.min
  end

  def pessimistic_max_num_calls_to_enqueue
    [
      ((max_calls_to_enqueue || callout_participations_to_call.count) - phone_calls_waiting_for_completion.count),
      pessimistic_min_calls_to_enqueue
    ].max
  end

  private

  def phone_calls_waiting_for_completion
    PhoneCall.waiting_for_completion
  end

  def calls_remaining_in_period
    [(max_calls_per_period - calls_queued_in_period.count), 0].max
  end

  def calls_queued_in_period
    PhoneCall.in_last_hours(max_calls_per_period_hours, :remotely_queued_at)
  end

  def max_calls_per_period
    ENV["ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD"].to_i if ENV["ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD"].present?
  end

  def max_calls_per_period_hours
    (ENV["ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS"].presence || DEFAULT_MAX_CALLS_PER_PERIOD_HOURS).to_i
  end

  def pessimistic_min_calls_to_enqueue
    (ENV["ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE"].presence || DEFAULT_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE).to_i
  end
end
