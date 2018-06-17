module Breadcrumbs
  extend ActiveSupport::Concern

  BREADCRUMB_ACTION_NAMES = {
    "create" => "new",
    "update" => "edit"
  }.freeze

  private

  def prepare_breadcrumbs
    add_parent_breadcrumbs if parent_resource
    add_breadcrumb(resources_title(association_chain), resources_path)
    add_breadcrumb(breadcrumb_action_title(:show, resource), show_location(resource)) if resource&.persisted?
    add_breadcrumb(breadcrumb_action_title(breadcrumb_action_name)) if %w[new edit].include?(breadcrumb_action_name)
  end

  def add_parent_breadcrumbs
    add_breadcrumb(resources_title(parent_resource), parent_resources_path)
    add_breadcrumb(breadcrumb_action_title(:show, parent_resource), show_location(parent_resource))
  end

  def resources_title(model)
    model.model_name.human.pluralize
  end

  def breadcrumb_action_name
    BREADCRUMB_ACTION_NAMES.fetch(action_name) { action_name }
  end

  def breadcrumb_action_title(action_name, resource = nil)
    I18n.t(:"breadcrumbs.#{action_name}", id: resource&.id)
  end
end
