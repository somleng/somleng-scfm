class BatchOperation::CalloutPopulation < BatchOperation::Base
  belongs_to :callout

  has_many :callout_participations,
           :foreign_key => :callout_population_id,
           :dependent => :restrict_with_error

  has_many :contacts, :through => :callout_participations

  def contact_filter_params
    parameters["contact_filter_params"] || {}
  end

  def contact_filter_params=(value)
    parameters["contact_filter_params"] = value
  end

  def run!
    callout_population_preview.contacts.find_each do |contact|
      create_callout_participation(contact)
    end
  end

  private

  def create_callout_participation(contact)
    CalloutParticipation.create(
      :contact => contact,
      :callout => callout,
      :callout_population => self
    )
  end

  def callout_population_preview
    @callout_population_preview ||= CalloutPopulationPreview.new(
      :callout_population => self
    )
  end
end
