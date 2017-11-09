class CalloutPopulation < ApplicationRecord
  include MetadataHelpers
  include Wisper::Publisher

  conditionally_serialize(:contact_filter_params, JSON)

  has_many :callout_participations, :dependent => :restrict_with_error
  has_many :contacts, :through => :callout_participations
  belongs_to :callout

  include AASM

  aasm :column => :status do
    state :preview, :initial => true
    state :queued
    state :populating
    state :populated

    event :queue, :after_commit => :publish_queued do
      transitions(
        :from => :preview,
        :to => :queued
      )
    end

    event :start do
      transitions(
        :from => :queued,
        :to => :populating
      )
    end

    event :finish do
      transitions(
        :from => :populating,
        :to => :populated
      )
    end

    event :requeue, :after_commit => :publish_queued do
      transitions(
        :from => :populated,
        :to => :queued
      )
    end
  end

  def self.contact_filter_params_has_values(hash)
    json_has_values(hash, :contact_filter_params)
  end

  private

  def publish_queued
    broadcast(:callout_population_queued, self)
  end
end
