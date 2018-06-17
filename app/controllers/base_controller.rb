class BaseController < ApplicationController
  def index
    find_resources
    _prepare_for_render
    respond_with_resources
  end

  def create
    build_resource_from_params
    prepare_resource_for_create
    save_resource
    after_create_resource
    _prepare_for_render
    respond_with_created_resource
  end

  def update
    find_resource
    before_update_attributes
    update_resource_attributes
    prepare_resource_for_update
    save_resource
    after_update_resource
    _prepare_for_render
    respond_with_updated_resource
  end

  def destroy
    find_resource
    prepare_resource_for_destroy
    destroy_resource
    _prepare_for_render
    respond_with_destroyed_resource
  end

  def show
    find_resource
    _prepare_for_render
    respond_with_resource
  end

  private

  attr_reader :resource, :resources

  def find_resource
    @resource = association_chain.find(params[:id])
  end

  def build_resource_from_params
    @resource = build_resource_association_chain.build(permitted_create_params)
  end

  def permitted_create_params
    permitted_params
  end

  def build_resource_association_chain
    association_chain
  end

  def prepare_resource_for_create
    prepare_resource
  end

  def after_create_resource
    after_save_resource
  end

  def after_update_resource
    after_save_resource
  end

  def after_save_resource; end

  def save_resource
    resource.save
  end

  def _prepare_for_render; end

  def respond_with_created_resource
    respond_with_resource
  end

  def respond_with_destroyed_resource
    respond_with_resource(location: resources_path)
  end

  def respond_with_resource(location: nil)
    respond_with(*respond_with_resource_parts, location: -> { location || show_location(resource) })
  end

  def respond_with_resources
    respond_with(resources)
  end

  def update_resource_attributes
    resource.assign_attributes(permitted_update_params)
  end

  def permitted_update_params
    permitted_params
  end

  def prepare_resource_for_update
    prepare_resource
  end

  def respond_with_updated_resource
    respond_with_resource
  end

  def prepare_resource_for_destroy
    prepare_resource
  end

  def prepare_resource; end

  def before_update_attributes; end

  def destroy_resource
    resource.destroy
  end

  def parent_resource; end
end
