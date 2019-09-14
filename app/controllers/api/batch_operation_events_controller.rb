module API
  class BatchOperationEventsController < API::ResourceEventsController
    private

    def prepare_resource_for_create
      subscribe_listeners
    end

    def subscribe_listeners
      batch_operation.subscribe(BatchOperationObserver.new)
    end

    def parent_resource
      batch_operation
    end

    def path_to_parent
      api_batch_operation_path(batch_operation)
    end

    def batch_operation
      @batch_operation ||= current_account.batch_operations.find(params[:batch_operation_id])
    end

    def event_class
      Event::BatchOperation
    end

    def access_token_write_permissions
      [:batch_operations_write]
    end
  end
end
