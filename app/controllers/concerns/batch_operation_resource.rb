module BatchOperationResource
  private

  def batch_operation
    @batch_operation ||= batch_operation_scope.find(params[:batch_operation_id])
  end

  def batch_operation_scope
    permitted_batch_operation_types.any? ? BatchOperation::Base.where(:type => permitted_batch_operation_types) : BatchOperation::Base.all
  end

  def permitted_batch_operation_types
    []
  end
end
