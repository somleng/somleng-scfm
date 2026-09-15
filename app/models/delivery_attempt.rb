class DeliveryAttempt < ApplicationRecord
  attribute :phone_number, :phone_number

  belongs_to :notification, counter_cache: true
  belongs_to :beneficiary
  belongs_to :broadcast

  delegate :account, to: :broadcast
  delegate :initiated?, :transition_to!, :may_transition_to?, to: :state_machine

  enumerize :error_code, in: [ :phone_number_unreachable ]

  class StateMachine < ::StateMachine::ActiveRecord
    state :created, initial: true, transitions_to: :queued
    state :queued, transitions_to: [ :initiated, :failed ]
    state :initiated, transitions_to: [ :failed, :succeeded ]
    state :failed
    state :succeeded
  end

  def completed?
    completed_at.present?
  end

  private

  def state_machine
    @state_machine ||= StateMachine.new(self)
  end
end
