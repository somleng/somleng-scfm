class Dashboard::BatchOperationEventsController < Dashboard::EventsController
  private

  def prepare_resource_for_create
    batch_operation.subscribe(BatchOperationObserver.new)
  end

  def parent_resource
    batch_operation
  end

  def batch_operation
    @batch_operation ||= current_account.batch_operations.find(params[:batch_operation_id])
  end

  def event_class
    Event::BatchOperation
  end
end
