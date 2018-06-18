class Dashboard::BatchOperationsController < Dashboard::BaseController
  helper_method :callout, :index_location

  private

  def parent_resource
    callout if params[:callout_id]
  end

  def association_chain
    if params[:callout_id]
      callout.batch_operations
    else
      current_account.batch_operations
    end
  end

  def callout
    @callout ||= current_account.callouts.find(params[:callout_id]) if params[:callout_id]
  end
end
