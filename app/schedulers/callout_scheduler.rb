class CalloutScheduler < ApplicationScheduler
  def run
    callout.phone_numbers.no_phone_calls_or_last_attempt(:failed).limit(num_phone_calls_to_enqueue).find_each do |phone_call|
    end
  end

  def callout
    @callout ||= find_callout
  end

  def find_callout
    Callout.first!
  end
end
