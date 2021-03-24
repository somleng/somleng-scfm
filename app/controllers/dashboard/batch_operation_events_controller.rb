module Dashboard
  class BatchOperationEventsController < Dashboard::EventsController
    private

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
end
