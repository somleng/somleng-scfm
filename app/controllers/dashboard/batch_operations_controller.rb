class Dashboard::BatchOperationsController < Dashboard::BaseController
  def index
    @batch_operations = association_chain.page(params[:page])
  end

  def new
    @batch_operation = association_chain.new
  end

  def create
    @batch_operation = association_chain.build(permitted_params)
    save_resource
    respond_with_resource
  end

  def show
    find_resource
  end

  private

  def association_chain
    BatchOperation::Base.from_type_param(
      params.dig(:batch_operation, :type)
    ).where(account_id: current_account.id)
  end

  def permitted_params
    params.require(:batch_operation).permit(
      metadata_forms_attributes: %i[attr_key attr_val]
    )
  end

  def save_resource
    resource.save
  end

  def find_resource
    @batch_operation = association_chain.find(params[:id])
  end

  def resource
    @batch_operation
  end

  def respond_with_resource(location: nil)
    respond_with resource, location: -> { location || show_location }
  end

  def show_location
    dashboard_batch_operation_path(resource)
  end
end
