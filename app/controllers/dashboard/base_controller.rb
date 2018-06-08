require "application_responder"

class Dashboard::BaseController < ApplicationController
  KEY_VALUE_FIELD_ATTRIBUTES = %i[key value].freeze

  METADATA_FIELDS_ATTRIBUTES = {
    metadata_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES
  }.freeze

  self.responder = ApplicationResponder
  respond_to :html

  before_action :authenticate_user!
  before_action :set_locale
  before_action :find_resource, only: %i[show edit update destroy]

  helper_method :resource, :resources, :show_location, :current_account

  def index
    find_resources
  end

  def new
    build_new_resource
    prepare_new_resource
  end

  def create
    build_resource_from_params
    prepare_resource_for_create
    save_resource
    prepare_for_render_on_create
    respond_with_created_resource
  end

  def edit
    prepare_resource_for_edit
  end

  def update
    before_update_attributes
    update_resource_attributes
    prepare_resource_for_update
    save_resource
    prepare_for_render_on_update
    respond_with_updated_resource
  end

  def destroy
    prepare_resource_for_destroy
    destroy_resource
    respond_with_destroyed_resource
  end

  private

  attr_reader :resource, :resources

  def build_new_resource
    @resource = association_chain.new
  end

  def respond_with_created_resource
    respond_with_resource
  end

  def respond_with_updated_resource
    respond_with_resource
  end

  def respond_with_destroyed_resource
    respond_with(*respond_with_resource_parts, location: resources_path) do |format|
      format.html { redirect_to(show_location(resource)) } unless resource.destroy
    end
  end

  def prepare_new_resource
    build_key_value_fields
  end

  def build_resource_from_params
    @resource = association_chain.build(permitted_params)
  end

  def prepare_resource_for_edit
    build_key_value_fields
  end

  def prepare_resource_for_create; end

  def prepare_resource_for_update; end

  def before_update_attributes; end

  def prepare_resource_for_destroy; end

  def prepare_for_render_on_create
    build_key_value_fields
  end

  def prepare_for_render_on_update
    build_key_value_fields
  end

  def build_key_value_fields; end

  def build_metadata_field
    resource.build_metadata_field if resource.metadata_fields.empty?
  end

  def find_resources
    @resources = association_chain.page(params[:page])
  end

  def update_resource_attributes
    resource.assign_attributes(permitted_params)
  end

  def clear_metadata
    resource.metadata.clear
  end

  def save_resource
    resource.save
  end

  def destroy_resource
    resource.destroy
  end

  def find_resource
    @resource = association_chain.find(params[:id])
  end

  def respond_with_resource(location: nil)
    respond_with(*respond_with_resource_parts, location: -> { location || show_location(resource) })
  end

  def respond_with_resource_parts
    [:dashboard, resource]
  end

  def show_location(resource)
    polymorphic_path([:dashboard, resource])
  end

  def current_account
    current_user.account
  end

  def set_locale
    I18n.locale = current_user.locale
  end
end
