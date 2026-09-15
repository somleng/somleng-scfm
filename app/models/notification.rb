class Notification < ApplicationRecord
  attribute :phone_number, :phone_number

  belongs_to :broadcast
  belongs_to :beneficiary, optional: true

  has_many :delivery_attempts

  delegate :account, to: :broadcast
  delegate :transition_to!, :transition_to, to: :state_machine

  validates :beneficiary, presence: true, on: :create

  before_create :set_phone_number

  class StateMachine < ::StateMachine::ActiveRecord
    state :pending, initial: true, transitions_to: [ :failed, :succeeded ]
    state :failed
    state :succeeded
  end

  enumerize :status, in: StateMachine.state_definitions.map(&:name)

  def completed?
    completed_at.present?
  end

  def max_delivery_attempts_reached?
    delivery_attempts_count >= account.max_delivery_attempts_for_notification
  end

  private

  def set_phone_number
    self.phone_number = beneficiary.phone_number
  end

  def state_machine
    @state_machine ||= StateMachine.new(self)
  end
end
