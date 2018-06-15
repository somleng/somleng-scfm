class Api::BaseController < BaseController
  protect_from_forgery with: :null_session
  before_action :verify_requested_format!

  private

  def respond_with_resource_parts
    [:api, resource]
  end

  def show_location(resource)
    polymorphic_path([:api, resource])
  end

  def resources_path
    polymorphic_path([:api, association_chain.model])
  end
end
