class BatchOperation::PhoneCallQueue < BatchOperation::PhoneCallEventOperation
  include CustomRoutesHelper["batch_operations"]

  has_many :phone_calls,
           class_name: "PhoneCall",
           foreign_key: :queue_batch_operation_id,
           dependent: :restrict_with_error

  private

  def applied_limit
    limit || calculate_limit
  end

  def assign_batch_operation(phone_call)
    phone_call.queue_batch_operation = self
  end

  def fire_event!(phone_call)
    phone_call.queue!
  end

  def batch_operation_account_settings_param
    "batch_operation_phone_call_queue_parameters"
  end
end
