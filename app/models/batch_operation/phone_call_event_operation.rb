# == Schema Information
#
# Table name: batch_operations
#
#  id         :integer          not null, primary key
#  callout_id :integer
#  parameters :jsonb            not null
#  metadata   :jsonb            not null
#  status     :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer          not null
#

class BatchOperation::PhoneCallEventOperation < BatchOperation::PhoneCallOperation
  store_accessor :parameters,
                 :phone_call_filter_params

  hash_store_reader :phone_call_filter_params

  validates :phone_calls_preview,
            :presence => true,
            :unless => :skip_validate_preview_presence?

  def run!
    phone_calls_preview.find_each do |phone_call|
      phone_call.subscribe(PhoneCallObserver.new)
      set_batch_operation(phone_call)
      fire_event!(phone_call)
    end
  end

  def phone_calls_preview
    preview.phone_calls.limit(applied_limit)
  end

  private

  def preview
    @preview ||= Preview::PhoneCallEventOperation.new(:previewable => self)
  end
end
