class Dashboard::CalloutPopulationsController < Dashboard::BaseController
  helper_method :callout

  private

  attr_accessor :callout

  def association_chain
    find_callout.callout_populations
  end

  def permitted_params
    params.fetch(:batch_operation_callout_population, {}).permit(
      contact_filter_metadata_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES
    )
  end

  def show_location(resource)
    dashboard_callout_callout_population_path(callout, resource)
  end

  def resources_path
    dashboard_callout_callout_populations_path(callout)
  end

  def prepare_resource_for_create
    resource.account = callout.account
  end

  def find_callout
    @callout = current_account.callouts.find(params[:callout_id])
  end

  def build_key_value_fields
    resource.build_contact_filter_metadata_field if resource.contact_filter_metadata_fields.empty?
  end
end
