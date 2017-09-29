class Callout < ApplicationRecord
  include MetadataHelpers

  has_many :phone_numbers
  has_many :phone_calls, :through => :phone_numbers

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
