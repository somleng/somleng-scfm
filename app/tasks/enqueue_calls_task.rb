class EnqueueCallsTask < ApplicationTask
  DEFAULT_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE = 1
  DEFAULT_ENQUEUE_STRATEGY = "optimistic"
  ENQUEUE_STRATEGIES = [DEFAULT_ENQUEUE_STRATEGY, "pessimistic"]

  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :enqueue_calls_task_max_calls_to_enqueue => "30",
      :enqueue_calls_task_enqueue_strategy => "optimistic",
      :enqueue_calls_task_pessimistic_min_calls_to_enqueue => "1",
      :enqueue_calls_task_remote_call_params => '{"from":"1234","url":"http://demo.twilio.com/docs/voice.xml","method":"GET"}'
    }

    def self.default_env_vars(task_name)
      super.merge(DEFAULT_ENV_VARS).merge(default_somleng_env_vars(task_name))
    end
  end

  def run!
    phone_numbers_to_call.limit(num_calls_to_enqueue).find_each do |phone_number|
      phone_call = schedule_phone_call!(phone_number)
      enqueue_phone_call!(phone_call)
    end
  end

  def optimistic_num_calls_to_enqueue
    max_calls_to_enqueue
  end

  def pessimistic_num_calls_to_enqueue
    [
      ((max_calls_to_enqueue || phone_numbers_to_call.count) - phone_calls_waiting_for_completion.count),
      pessimistic_min_calls_to_enqueue
    ].max
  end

  def phone_numbers_to_call
    PhoneNumber.from_running_callout.no_phone_calls_or_last_attempt(:failed)
  end

  private

  def phone_calls_waiting_for_completion
    PhoneCall.waiting_for_completion
  end

  def schedule_phone_call!(phone_number)
    phone_call = phone_number.phone_calls.new
    phone_call.schedule!
    phone_call
  end

  def enqueue_phone_call!(phone_call)
    begin
      response = queue_remote_call!(phone_call.phone_number)
      phone_call.remote_call_id = response.sid
    rescue Twilio::REST::RestError => e
      phone_call.remote_error_message = e.message
    end

    phone_call.queue!
  end

  def queue_remote_call!(phone_number)
    somleng_client.api.account.calls.create(
      default_call_params.merge(call_params(phone_number))
    )
  end

  def call_params(phone_number)
    {
      :to => phone_number.msisdn
    }
  end

  def somleng_client
    @somleng_client ||= Somleng::Client.new
  end

  def num_calls_to_enqueue
    send("#{enqueue_strategy}_num_calls_to_enqueue")
  end

  def enqueue_strategy
    Hash[ENQUEUE_STRATEGIES.map {|k| [k, k] }][ENV["ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY"]] ||DEFAULT_ENQUEUE_STRATEGY
  end

  def max_calls_to_enqueue
    ENV["ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE"].to_i if ENV["ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE"]
  end

  def pessimistic_min_calls_to_enqueue
    (ENV["ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE"] || DEFAULT_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE).to_i
  end

  def default_call_params
    @default_call_params ||= JSON.parse(ENV["ENQUEUE_CALLS_TASK_DEFAULT_CALL_PARAMS"] || "{}").symbolize_keys
  end
end
