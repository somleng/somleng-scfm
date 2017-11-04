class Api::BaseController < ApplicationController
  before_action :verify_requested_format!
  respond_to :xml

  def create
    build_resource
    setup_resource
    save_resource
    respond_with_create_resource
  end

  private

  def respond_with_create_resource
    respond_with(resource, :location => Proc.new { api_phone_call_event_url(resource) })
  end

  def build_resource
    @resource = association_chain.new(permitted_params)
  end

  def setup_resource
  end

  def save_resource
    resource.save
  end

  def resource
    @resource
  end
end
