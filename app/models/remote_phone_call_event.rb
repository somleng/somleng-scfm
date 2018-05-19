class RemotePhoneCallEvent < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic
  include Wisper::Publisher

  belongs_to :phone_call, validate: true, autosave: true

  validates :call_flow_logic,
            presence: true

  validates :remote_call_id,
            :remote_direction,
            presence: true

  delegate :contact,
           to: :phone_call

  delegate :complete!,
           to: :phone_call,
           prefix: true

  def setup!
    broadcast(:remote_phone_call_event_initialized, self)
  end
end
