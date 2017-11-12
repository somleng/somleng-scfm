class Api::BatchOperationEventsController < Api::ResourceEventsController
  private

  def setup_resource
    subscribe_listeners
  end

  def subscribe_listeners
    batch_operation.subscribe(BatchOperationObserver.new)
  end

  def parent
    batch_operation
  end

  def path_to_parent
    api_batch_operation_path(batch_operation)
  end

  def batch_operation
    @batch_operation ||= BatchOperation::Base.find(params[:batch_operation_id])
  end

  def event_class
    Event::BatchOperation
  end
end
