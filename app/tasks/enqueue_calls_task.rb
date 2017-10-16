class EnqueueCallsTask < ApplicationTask
  DEFAULT_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE = 1
  DEFAULT_ENQUEUE_STRATEGY = "optimistic"
  ENQUEUE_STRATEGIES = [DEFAULT_ENQUEUE_STRATEGY, "pessimistic"]
  DEFAULT_MAX_CALLS_PER_PERIOD_HOURS = 24

  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :enqueue_calls_task_max_calls_to_enqueue => "30",
      :enqueue_calls_task_enqueue_strategy => "optimistic",
      :enqueue_calls_task_pessimistic_min_calls_to_enqueue => "1",
      :enqueue_calls_task_default_somleng_request_params => "{\\\"from\\\":\\\"1234\\\",\\\"url\\\":\\\"http://demo.twilio.com/docs/voice.xml\\\",\\\"method\\\":\\\"GET\\\"}"
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

  def optimistic_max_num_calls_to_enqueue
    max_calls_to_enqueue
  end

  def pessimistic_max_num_calls_to_enqueue
    [
      ((max_calls_to_enqueue || callout_participations_to_call.count) - phone_calls_waiting_for_completion.count),
      pessimistic_min_calls_to_enqueue
    ].max
  end

  def callout_participations_to_call
    CalloutParticipation.from_running_callout.remaining
  end

  private

  def phone_calls_waiting_for_completion
    PhoneCall.waiting_for_completion
  end

  def schedule_phone_call!(callout_participation)
    phone_call = callout_participation.phone_calls.new
    phone_call.contact_id = callout_participation.contact_id
    phone_call.schedule!
    phone_call
  end

  def enqueue_phone_call!(phone_call)
    begin
      response = queue_remote_call!(phone_call.callout_participation)
      phone_call.remote_call_id = response.sid
      phone_call.remote_direction = response.direction
    rescue Twilio::REST::RestError => e
      phone_call.remote_error_message = e.message
    end

    phone_call.queue!
  end

  def queue_remote_call!(callout_participation)
    somleng_client.api.account.calls.create(
      default_somleng_request_params.merge(somleng_request_params(callout_participation))
    )
  end

  def somleng_request_params(callout_participation)
    {
      :to => callout_participation.msisdn
    }
  end

  def somleng_client
    @somleng_client ||= Somleng::Client.new
  end

  def calls_remaining_in_period
    [(max_calls_per_period - calls_queued_in_period.count), 0].max
  end

  def calls_queued_in_period
    PhoneCall.in_last_hours(max_calls_per_period_hours, :queued_at)
  end

  def enqueue_strategy
    Hash[ENQUEUE_STRATEGIES.map {|k| [k, k] }][ENV["ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY"].presence] ||DEFAULT_ENQUEUE_STRATEGY
  end

  def max_calls_to_enqueue
    ENV["ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE"].to_i if ENV["ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE"].present?
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

  def default_somleng_request_params
    @default_somleng_request_params ||= JSON.parse(ENV["ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS"].presence || "{}").symbolize_keys
  end
end
