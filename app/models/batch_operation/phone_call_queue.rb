class BatchOperation::PhoneCallQueue < BatchOperation::PhoneCallEventOperation
  has_many :phone_calls,
           :class_name => "PhoneCall",
           :foreign_key => :queue_batch_operation_id,
           :dependent => :restrict_with_error

  private

  def applied_limit
    limit || calculate_limit
  end

  def set_batch_operation(phone_call)
    phone_call.queue_batch_operation = self
  end

  def fire_event!(phone_call)
    phone_call.queue!
  end
end
