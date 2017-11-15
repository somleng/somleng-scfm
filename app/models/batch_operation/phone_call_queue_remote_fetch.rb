class BatchOperation::PhoneCallQueueRemoteFetch < BatchOperation::PhoneCallEventOperation
  has_many :phone_calls,
           :class_name => "PhoneCall",
           :foreign_key => :queue_remote_fetch_batch_operation_id,
           :dependent => :restrict_with_error

  private

  def set_batch_operation(phone_call)
    phone_call.queue_remote_fetch_batch_operation = self
  end

  def fire_event!(phone_call)
    phone_call.queue_remote_fetch!
  end

  def applied_limit
    limit
  end
end
