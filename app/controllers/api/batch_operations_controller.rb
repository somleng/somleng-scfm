module API
  class BatchOperationsController < API::BaseController
    include ValidateSchemaController
    self.request_schema = CalloutPopulationRequestSchema

    respond_to :json

    private

    def filter_class
      Filter::Resource::BatchOperation
    end

    def build_resource_association_chain
      nested_resources_association_chain
    end

    def find_resources_association_chain
      nested_resources_association_chain
    end

    def nested_resources_association_chain
      if params[:callout_id]
        association_chain.where(callout_id: params[:callout_id])
      else
        association_chain
      end
    end

    def association_chain
      BatchOperation::Base.from_type_param(
        params[:type]
      ).where(account_id: current_account.id)
    end

    def permitted_params
      params.permit(:metadata_merge_mode, :type, metadata: {}, parameters: {})
    end

    def show_location(resource)
      api_batch_operation_path(resource)
    end

    def resources_path
      api_batch_operations_path
    end
  end
end
