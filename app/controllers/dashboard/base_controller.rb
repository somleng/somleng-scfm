require "application_responder"

module Dashboard
  class BaseController < ::BaseController
    include Breadcrumbs

    KEY_VALUE_FIELD_ATTRIBUTES = %i[key value].freeze

    METADATA_FIELDS_ATTRIBUTES = {
      metadata_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES
    }.freeze

    self.responder = ApplicationResponder
    respond_to :html

    before_action :authenticate_user!, :set_locale
    helper_method :resource, :resources, :show_location, :resources_path,
                  :current_account, :sort_params

    def new
      build_new_resource
      prepare_resource_for_new
      _prepare_for_render
    end

    def edit
      find_resource
      prepare_resource_for_edit
      _prepare_for_render
    end

    private

    def build_new_resource
      @resource = association_chain.new
    end

    def find_resources
      @resources = super.page(params[:page])
    end

    def respond_with_destroyed_resource
      respond_with(*respond_with_resource_parts, location: resources_path) do |format|
        format.html { redirect_to(show_location(resource)) } unless resource.destroy
      end
    end

    def prepare_resource_for_new
      build_key_value_fields
    end

    def prepare_resource_for_edit
      build_key_value_fields
    end

    def after_save_resource
      build_key_value_fields
    end

    def build_key_value_fields; end

    def build_metadata_field
      resource.build_metadata_field if resource.metadata_fields.empty?
    end

    def clear_metadata
      resource.metadata.clear
    end

    def respond_with_resource_parts
      [:dashboard, resource]
    end

    def show_location(resource)
      polymorphic_path([:dashboard, resource])
    end

    def resources_path
      polymorphic_path([:dashboard, parent_resource, association_chain.model])
    end

    def parent_resources_path
      polymorphic_path([:dashboard, parent_resource.class])
    end

    def current_account
      current_user.account
    end

    def set_locale
      I18n.locale = current_user.locale
    end

    def _prepare_for_render
      prepare_breadcrumbs
    end
  end
end
