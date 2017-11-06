class CalloutEvent
  include ActiveModel::Validations
  attr_accessor :callout, :event

  validates :callout, :presence => true

  validates :event,
            :inclusion => { :in => Proc.new { Callout.aasm.events.map { |event| event.name.to_s } } }

  def initialize(options = {})
    self.callout = options[:callout]
    self.event = options[:event]
  end

  def save
    if valid?
      callout.aasm.fire!(event.to_sym)
    else
      false
    end
  end
end
