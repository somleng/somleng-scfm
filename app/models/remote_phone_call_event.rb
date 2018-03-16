# == Schema Information
#
# Table name: remote_phone_call_events
#
#  id               :integer          not null, primary key
#  phone_call_id    :integer          not null
#  details          :jsonb            not null
#  metadata         :jsonb            not null
#  remote_call_id   :string           not null
#  remote_direction :string           not null
#  call_flow_logic  :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class RemotePhoneCallEvent < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic
  include Wisper::Publisher

  conditionally_serialize(:details, JSON)

  belongs_to :phone_call, :validate => true, :autosave => true

  validates :call_flow_logic,
            :presence => true

  validates :remote_call_id,
            :remote_direction,
            :presence => true

  delegate :contact,
           :to => :phone_call

  delegate :complete!,
           :to => :phone_call,
           :prefix => true

  def setup!
    broadcast(:remote_phone_call_event_initialized, self)
  end
end
