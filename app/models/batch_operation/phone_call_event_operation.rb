class BatchOperation::PhoneCallEventOperation < BatchOperation::PhoneCallOperation
  include CustomRoutesHelper["batch_operations"]

  store_accessor :parameters,
                 :phone_call_filter_params

  hash_store_reader :phone_call_filter_params

  validates :phone_calls_preview,
            presence: true,
            unless: :skip_validate_preview_presence?

  def run!
    # Using find_each will override random order
    phone_calls_preview.each do |phone_call|
      phone_call.subscribe(PhoneCallObserver.new)
      assign_batch_operation(phone_call)
      phone_call.save!
      fire_event!(phone_call)
    end
  end

  def phone_calls_preview
    preview.phone_calls(
      scope: account.phone_calls
    ).order(Arel.sql("RANDOM()")).limit(applied_limit)
  end

  private

  def preview
    Preview::PhoneCallEventOperation.new(previewable: self)
  end
end
