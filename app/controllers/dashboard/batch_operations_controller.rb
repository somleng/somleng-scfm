class Dashboard::BatchOperationsController < Dashboard::BaseController
  helper_method :callout, :index_location

  private

  attr_accessor :callout

  def association_chain
    if params[:callout_id]
      find_callout.batch_operations
    else
      current_account.batch_operations
    end
  end

  def find_callout
    @callout = current_account.callouts.find(params[:callout_id])
  end

  def index_location
    if callout
      dashboard_callout_batch_operations_path(callout)
    else
      dashboard_batch_operations_path
    end
  end

  def show_location(resource)
    dashboard_batch_operation_path(resource)
  end

  def resources_path
    polymorphic_path([:dashboard, callout, :batch_operations])
  end
end
