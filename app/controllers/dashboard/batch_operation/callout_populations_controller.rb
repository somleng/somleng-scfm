class Dashboard::BatchOperation::CalloutPopulationsController < Dashboard::BaseController
  helper_method :callout

  private

  attr_accessor :callout

  def association_chain
    if params[:callout_id]
      find_callout.callout_populations
    else
      current_account.batch_operations
    end
  end

  def permitted_params
    params.fetch(:batch_operation_callout_population, {}).permit(
      contact_filter_metadata_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES
    )
  end

  def show_location(resource)
    dashboard_batch_operation_path(resource)
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
