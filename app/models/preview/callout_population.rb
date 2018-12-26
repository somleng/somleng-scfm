module Preview
  class CalloutPopulation < Preview::Base
    def contacts(scope:)
      contact_filter(scope: scope).resources
    end

    private

    def contact_filter(scope:)
      Filter::Resource::Contact.new(
        {
          association_chain: scope
        },
        previewable.contact_filter_params.with_indifferent_access
      )
    end
  end
end
