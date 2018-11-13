class BatchOperation::PhoneCallQueueRemoteFetch < BatchOperation::PhoneCallEventOperation
  include CustomRoutesHelper["batch_operations"]

  has_many :phone_calls,
           class_name: "PhoneCall",
           foreign_key: :queue_remote_fetch_batch_operation_id,
           dependent: :restrict_with_error

  private

  def set_batch_operation(phone_call)
    phone_call.queue_remote_fetch_batch_operation = self
  end

  def fire_event!(phone_call)
    FetchRemoteCallJob.perform_later(phone_call.id)
  end

  def applied_limit
    limit
  end

  def batch_operation_account_settings_param
    "batch_operation_phone_call_queue_remote_fetch_parameters"
  end
end
