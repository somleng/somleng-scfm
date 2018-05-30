class BatchOperation::CalloutPopulation < BatchOperation::Base
  belongs_to :callout

  has_many :callout_participations,
           foreign_key: :callout_population_id,
           dependent: :restrict_with_error

  has_many :contacts, through: :callout_participations

  store_accessor :parameters,
                 :contact_filter_params

  hash_store_reader :contact_filter_params

  accepts_nested_key_value_fields_for :contact_filter_metadata

  def run!
    contacts_preview.find_each do |contact|
      create_callout_participation(contact)
    end
  end

  def contacts_preview
    preview.contacts(scope: account.contacts)
  end

  def contact_filter_metadata
    contact_filter_params.with_indifferent_access[:metadata] || {}
  end

  def contact_filter_metadata=(attributes)
    return if attributes.blank?
    self.contact_filter_params = { "metadata" => attributes }
  end

  private

  def preview
    @preview ||= Preview::CalloutPopulation.new(previewable: self)
  end

  def create_callout_participation(contact)
    CalloutParticipation.create(
      contact: contact,
      callout: callout,
      callout_population: self
    )
  end
end
