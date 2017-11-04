class PhoneCallEvent < ApplicationRecord
  include ConditionalSerialization
  conditionally_serialize(:details, JSON)

  belongs_to :phone_call, :validate => true
  delegate :call_flow_logic, :to => :phone_call
end
