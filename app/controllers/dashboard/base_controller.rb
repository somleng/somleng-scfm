require "application_responder"

class Dashboard::BaseController < ApplicationController
  KEY_VALUE_FIELD_ATTRIBUTES = %i[key value].freeze

  METADATA_FIELDS_ATTRIBUTES = {
    metadata_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES
  }.freeze

  self.responder = ApplicationResponder
  respond_to :html

  before_action :authenticate_user!
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
    respond_with_resource
  end

  def edit
    prepare_resource_for_edit
  end

  def update
    prepare_resource_for_update
    update_resource_attributes
    save_resource
    prepare_for_render_on_update
    respond_with_resource
  end

  def destroy
    destroy_resource
    respond_with_resource(location: resources_path)
  end

  private

  attr_reader :resource, :resources

  def build_new_resource
    @resource = association_chain.new
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
    respond_with resource, location: -> { location || show_location(resource) }
  end

  def show_location(resource)
    polymorphic_path([:dashboard, resource])
  end

  def current_account
    current_user.account
  end
end
