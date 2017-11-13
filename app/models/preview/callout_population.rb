class Preview::CalloutPopulation < Preview::Base
  def contacts
    contact_filter.resources
  end

  private

  def contact_filter
    @contact_filter ||= Filter::Resource::Contact.new(
      {
        :association_chain => Contact
      },
      previewable.contact_filter_params.with_indifferent_access
    )
  end
end
