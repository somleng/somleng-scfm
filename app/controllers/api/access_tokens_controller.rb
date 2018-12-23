module Api
  class AccessTokensController < Api::BaseController
    private

    def find_resources_association_chain
      association_chain
    end

    def association_chain
      specified_or_current_account.access_tokens.all
    end

    def filter_class
      Filter::Resource::AccessToken
    end

    def permitted_params
      params.permit(:metadata_merge_mode, permissions: [], metadata: {})
    end

    def prepare_resource_for_create
      resource.created_by = current_account
    end

    def prepare_resource_for_destroy
      resource.destroyer = current_account
    end
  end
end
