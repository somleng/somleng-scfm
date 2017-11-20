class Callout < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic

  has_many :callout_participations, :dependent => :restrict_with_error

  has_many :batch_operations,
           :class_name => "BatchOperation::Base",
           :dependent => :restrict_with_error

  has_many :phone_calls,
           :through => :callout_participations

  has_many :remote_phone_call_events,
           :through => :phone_calls

  has_many :contacts,
           :through => :callout_participations

  alias_attribute :calls, :phone_calls

  validates :status, :presence => true

  include AASM

  aasm :column => :status, :whiny_transitions => false do
    state :initialized, :initial => true
    state :running
    state :paused
    state :stopped

    event :start do
      transitions(
        :from => :initialized,
        :to => :running
      )
    end

    event :pause do
      transitions(
        :from => :running,
        :to => :paused
      )
    end

    event :resume do
      transitions(
        :from => [:paused, :stopped],
        :to => :running
      )
    end

    event :stop do
      transitions(
        :from => [:running, :paused],
        :to => :stopped
      )
    end
  end
end
