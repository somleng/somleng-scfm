class CalloutParticipation < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers
  include HasCallFlowLogic

  DEFAULT_RETRY_STATUSES = [
    "failed"
  ].freeze

  belongs_to :callout
  belongs_to :contact
  belongs_to :callout_population,
             optional: true,
             class_name: "BatchOperation::CalloutPopulation"

  has_many :phone_calls,
           dependent: :restrict_with_error

  has_many :remote_phone_call_events, through: :phone_calls

  delegate :call_flow_logic, to: :callout, prefix: true, allow_nil: true
  delegate :msisdn, to: :contact, prefix: true, allow_nil: true

  before_validation :set_msisdn_from_contact,
                    :set_call_flow_logic,
                    on: :create

  def self.still_trying(max_phone_calls)
    where(answered: false).where(arel_table[:phone_calls_count].lt(max_phone_calls))
  end

  private

  def set_msisdn_from_contact
    self.msisdn ||= contact_msisdn
  end

  def set_call_flow_logic
    return if call_flow_logic.present?

    self.call_flow_logic = callout_call_flow_logic
  end
end
