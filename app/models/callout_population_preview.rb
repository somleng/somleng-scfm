class CalloutPopulationPreview
  attr_accessor :callout_population

  def initialize(options = {})
    self.callout_population = options[:callout_population]
  end

  def contacts
    contact_filter.resources
  end

  private

  def contact_filter
    @contact_filter ||= ContactFilter.new(
      {
        :association_chain => Contact
      },
      callout_population.contact_filter_params.with_indifferent_access
    )
  end
end
