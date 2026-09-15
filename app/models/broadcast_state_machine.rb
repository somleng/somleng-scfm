class BroadcastStateMachine
  attr_reader :current_status

  delegate :pending?, :errored?, :may_transition_to?, :transition_to!, to: :state_machine

  class StateMachine < ::StateMachine::Machine
    state :pending, initial: true, transitions_to: { running: { as: :queued } }
    state :queued
    state :errored, transitions_to: { running: { as: :queued } }
    state :running, transitions_to: :stopped
    state :stopped, transitions_to: :running
    state :completed
  end

  def initialize(current_status = nil)
    @current_status = current_status
  end

  def updatable?
    pending? || errored?
  end

  private

  def state_machine
    @state_machine ||= StateMachine.new(current_status)
  end
end
