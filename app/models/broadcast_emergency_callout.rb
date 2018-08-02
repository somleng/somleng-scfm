class BroadcastEmergencyCallout
  attr_reader :sensor_event, :callout, :callout_population
  delegate :sensor, :sensor_rule, to: :sensor_event
  delegate :account, to: :sensor

  def initialize(sensor_event)
    @sensor_event = sensor_event
  end

  def call
    build_callout
    build_callout_population
    save_callout
    queue_callout_population
    broadcast_message
  end

  private

  def build_callout
    @callout = account.callouts.new(
      call_flow_logic: Callout::DEFAULT_CALL_FLOW_LOGIC,
      commune_ids: sensor.commune_ids,
      audio_file: sensor_rule.alert_file.blob,
      sensor_event: sensor_event
    )
  end

  def build_callout_population
    @callout_population = callout.build_callout_population(
      account: account,
      contact_filter_params: contact_filter_params
    )
  end

  def save_callout
    callout.subscribe(CalloutObserver.new)
    callout.save!
  end

  def queue_callout_population
    callout_population.subscribe(BatchOperationObserver.new)
    callout_population.queue!
  end

  def broadcast_message
    callout.start!
  end

  def contact_filter_params
    { has_locations_in: callout.commune_ids }
  end
end
