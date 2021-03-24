module API
  class CalloutsController < API::BaseController
    private

    def find_resources_association_chain
      if params[:contact_id]
        contact.callouts
      else
        association_chain
      end
    end

    def association_chain
      current_account.callouts.all
    end

    def filter_class
      Filter::Resource::Callout
    end

    def permitted_params
      params.permit(
        :call_flow_logic,
        :audio_url,
        :metadata_merge_mode,
        metadata: {},
        settings: {}
      )
    end

    def contact
      @contact ||= current_account.contacts.find(params[:contact_id])
    end
  end
end
