class BatchOperation::PhoneCallQueue < BatchOperation::PhoneCallOperation
  DEFAULT_STRATEGY = "optimistic"
  STRATEGIES = [DEFAULT_STRATEGY, "pessimistic"]

  json_attr_accessor :phone_call_filter_params,
                     :maximum,
                     :strategy,
                     :maximum_per_period,
                     :json_attribute => :parameters

  hash_attr_reader   :phone_call_filter_params,
                     :json_attribute => :parameters

  integer_attr_reader :maximum,
                      :maximum_per_period,
                      :json_attribute => :parameters

  def run!
    phone_calls_preview.find_each do |phone_call|
      phone_call.subscribe(PhoneCallObserver.new)
      phone_call.queue!
    end
  end

  def phone_calls_preview
    preview.phone_calls.limit(max_calls_to_enqueue)
  end

  def preview
    Preview::PhoneCallQueue.new(:previewable => self)
  end

  def strategy
    Hash[STRATEGIES.map {|k| [k, k] }][parameters["strategy"]] || DEFAULT_STRATEGY
  end

  def max_calls_to_enqueue
    [
      send("#{strategy}_maximum"),
      max_calls_per_period && calls_remaining_in_period
    ].compact.min
  end

  private

  def optimistic_maximum
    maximum
  end
end
