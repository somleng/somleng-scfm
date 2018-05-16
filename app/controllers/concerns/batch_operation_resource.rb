module BatchOperationResource
  extend ActiveSupport::Concern

  included do
    helper_method :batch_operation
  end

  private

  def batch_operation
    @batch_operation ||= batch_operation_scope.find(params[:batch_operation_id])
  end
end
