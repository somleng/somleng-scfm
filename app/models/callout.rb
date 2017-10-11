class Callout < ApplicationRecord
  include MetadataHelpers

  has_many :callout_participants
  has_many :phone_calls, :through => :callout_participants
  has_many :contacts, :through => :callout_participants

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
