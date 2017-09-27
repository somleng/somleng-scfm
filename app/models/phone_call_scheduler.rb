class PhoneCallScheduler
  def schedule
    PhoneNumber.no_phone_calls_or_last_attempt(:failed).limit(num_phone_calls_to_enqueue).find_each do |phone_call|
    end
  end

  private

  def num_phone_calls_to_enqueue
  end
end
