module BatchOperationResource
  private

  def batch_operation
    @batch_operation ||= batch_operation_scope.find(params[:batch_operation_id])
  end

  def batch_operation_scope
    permitted_batch_operation_types.any? ? current_account.batch_operations.where(:type => permitted_batch_operation_types) : current_account.batch_operations.all
  end

  def permitted_batch_operation_types
    []
  end
end
