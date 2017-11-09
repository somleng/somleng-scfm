class PopulateCalloutJob < ApplicationJob
  attr_accessor :callout_population_id

  def perform(callout_population_id)
    self.callout_population_id = callout_population_id
    callout_population.start!
    callout_population_preview.contacts.find_each do |contact|
      callout_participation = build_callout_participation(contact)
      callout_participation.save
    end
    callout_population.finish!
  end

  private

  def build_callout_participation(contact)
    CalloutParticipation.new(
      :contact => contact,
      :callout => callout_population.callout,
      :callout_population => callout_population,
      :msisdn => contact.msisdn
    )
  end

  def callout_population_preview
    @callout_population_preview ||= CalloutPopulationPreview.new(
      :callout_population => callout_population
    )
  end

  def callout_population
    @callout_population ||= CalloutPopulation.find(callout_population_id)
  end
end
