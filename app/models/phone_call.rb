class PhoneCall < ApplicationRecord
  belongs_to :phone_number

  serialize :remote_response, JSON

  validates :remote_call_id, :uniqueness => {:case_sensitive => false}
  validates :status, :presence => true

  include AASM

  aasm :column => :status do
    state :new, :initial => true
    state :queued

    event :queue do
      transitions :from => :new,
                  :to => :queued
    end
  end
end
