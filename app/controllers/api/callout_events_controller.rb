class Api::CalloutEventsController < Api::AuthenticatedController
  respond_to :json

  private

  def respond_with_create_resource
    if resource.errors.any?
      respond_with(resource)
    else
      respond_with(callout, :location => api_callout_path(callout))
    end
  end

  def build_resource
    @resource = CalloutEvent.new(permitted_params.merge(:callout => callout))
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end

  def permitted_params
    params.permit(:event)
  end
end
