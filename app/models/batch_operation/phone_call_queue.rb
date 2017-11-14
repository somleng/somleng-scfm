class BatchOperation::PhoneCallQueue < BatchOperation::PhoneCallOperation
  has_many :phone_calls,
           :class_name => "PhoneCall",
           :foreign_key => :queue_batch_operation_id,
           :dependent => :restrict_with_error

  store_accessor :parameters,
                 :phone_call_filter_params

  hash_store_reader :phone_call_filter_params

  validates :phone_calls_preview,
            :presence => true,
            :unless => :skip_validate_preview_presence?

  def run!
    phone_calls_preview.find_each do |phone_call|
      phone_call.subscribe(PhoneCallObserver.new)
      phone_call.queue_batch_operation = self
      phone_call.queue!
    end
  end

  def phone_calls_preview
    preview.phone_calls.limit(limit || calculate_limit)
  end

  private

  def preview
    @preview ||= Preview::PhoneCallQueue.new(:previewable => self)
  end
end
