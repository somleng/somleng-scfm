class Event::Base
  include ActiveModel::Validations
  attr_accessor :eventable, :event

  validates :eventable, :presence => true

  validates :event,
            :inclusion => {
              :in => :valid_events
            }

  def initialize(options = {})
    self.eventable = options[:eventable]
    self.event = options[:event]
  end

  def save
    if valid?
      eventable.aasm.fire!(event.to_sym)
    else
      false
    end
  end

  private

  def valid_events
    eventable && eventable.aasm.events.map { |event| event.name.to_s } || []
  end
end
