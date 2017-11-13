class BatchOperation::PhoneCallCreate < BatchOperation::Base
  has_many :phone_calls,
           :foreign_key => :batch_operation_id,
           :dependent => :restrict_with_error

  has_many :contacts, :through => :phone_calls
  has_many :callout_participations, :through => :phone_calls

  validates :remote_request_params,
            :twilio_request_params => true,
            :presence => true

  hash_attr_accessor :remote_request_params,
                     :callout_filter_params,
                     :callout_participation_filter_params,
                     :attribute => :parameters

  def run!
    preview.callout_participations.find_each do |callout_participation|
      create_phone_call(callout_participation)
    end
  end

  def preview
    @preview ||= Preview::PhoneCallCreate.new(:previewable => self)
  end

  private

  def create_phone_call(callout_participation)
    PhoneCall.create(
      :callout_participation => callout_participation,
      :contact => callout_participation.contact,
      :batch_operation => self,
      :remote_request_params => remote_request_params
    )
  end
end
