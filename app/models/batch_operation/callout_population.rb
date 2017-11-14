class BatchOperation::CalloutPopulation < BatchOperation::Base
  belongs_to :callout

  has_many :callout_participations,
           :foreign_key => :callout_population_id,
           :dependent => :restrict_with_error

  has_many :contacts, :through => :callout_participations

  store_accessor :parameters, :contact_filter_params
  hash_store_reader   :contact_filter_params

  def run!
    preview.contacts.find_each do |contact|
      create_callout_participation(contact)
    end
  end

  def preview
    @preview ||= Preview::CalloutPopulation.new(:previewable => self)
  end

  private

  def create_callout_participation(contact)
    CalloutParticipation.create(
      :contact => contact,
      :callout => callout,
      :callout_population => self
    )
  end
end
