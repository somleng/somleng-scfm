module API
  class PhoneCallsController < API::BaseController
    private

    def find_resources_association_chain
      if params[:callout_participation_id]
        callout_participation.phone_calls
      elsif params[:callout_id]
        callout.phone_calls
      elsif params[:contact_id]
        contact.phone_calls
      else
        association_chain
      end
    end

    def association_chain
      current_account.phone_calls.all
    end

    def filter_class
      Filter::Resource::PhoneCall
    end

    def callout_participation
      @callout_participation ||= current_account.callout_participations.find(
        params[:callout_participation_id]
      )
    end

    def callout
      @callout ||= current_account.callouts.find(params[:callout_id])
    end

    def contact
      @contact ||= current_account.contacts.find(params[:contact_id])
    end
  end
end
