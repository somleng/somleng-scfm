class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :verify_requested_format!

  def create
    build_resource
    setup_resource
    save_resource
    after_save_resource
    respond_with_create_resource
  end

  def show
    find_resource
    respond_with_resource
  end

  def update
    find_resource
    update_resource
    respond_with_resource
  end

  def destroy
    find_resource
    before_destroy_resource
    destroy_resource
    respond_with_resource
  end

  private

  def respond_with_resource
    respond_with(resource)
  end

  def respond_with_create_resource
    respond_with(resource, respond_with_create_resource_options)
  end

  def respond_with_create_resource_options
    resource.persisted? ? { location: resource_location } : {}
  end

  def resource_location
    polymorphic_path([:api, resource])
  end

  def find_resource
    @resource = find_resource_association_chain.find(params[:id])
  end

  def find_resource_association_chain
    association_chain
  end

  def build_resource
    @resource = build_resource_association_chain.new(permitted_build_params)
  end

  def permitted_build_params
    permitted_params
  end

  def build_resource_association_chain
    association_chain
  end

  def setup_resource; end

  def save_resource
    resource.save
  end

  def after_save_resource; end

  def update_resource
    resource.update_attributes(permitted_update_params)
  end

  def permitted_update_params
    permitted_params
  end

  def before_destroy_resource; end

  def destroy_resource
    resource.destroy
  end

  attr_reader :resource, :resources
end
