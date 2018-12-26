module Dashboard
  class CalloutsController < Dashboard::BaseController
    helper_method :callout_summary

    private

    def association_chain
      current_account.callouts
    end

    def permitted_params
      params.fetch(:callout, {}).permit(
        :call_flow_logic,
        :audio_file,
        :audio_url,
        settings_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES,
        **METADATA_FIELDS_ATTRIBUTES
      )
    end

    def before_update_attributes
      clear_metadata
      resource.settings.clear
    end

    def build_key_value_fields
      build_metadata_field
      resource.build_settings_field if resource.settings_fields.empty?
    end

    def prepare_resource_for_create
      resource.subscribe(CalloutObserver.new)
      resource.created_by ||= current_user
    end

    def callout_summary
      @callout_summary ||= CalloutSummary.new(resource)
    end
  end
end
