class Import < ApplicationRecord
  belongs_to :user
  belongs_to :account

  attr_accessor :error_line

  enumerize :resource_type, in: %w[Beneficiary]

  has_one_attached :file

  validates :file, presence: true, attached: true, content_type: "text/csv"

  before_create :set_default_status

  delegate :transition_to!, to: :state_machine

  class StateMachine < ::StateMachine::ActiveRecord
    state :processing, initial: true, transitions_to: [ :failed, :succeeded ]
    state :failed
    state :succeeded
  end

  enumerize :status, in: StateMachine.state_definitions.map(&:name)

  private

  def state_machine
    StateMachine.new(self)
  end

  def set_default_status
    self.status ||= state_machine.current_state.name
  end
end
