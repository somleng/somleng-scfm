module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-danger"
    when :alert then "alert alert-danger"
    end
  end

  def title(resource = nil)
    translate(
      :"titles.#{controller_name}.#{action_name}",
      id: resource && resource.id,
      default: :"titles.app_name"
    )
  end

  def related_link_to(title, url, options = {})
    options[:class] ||= ""
    options[:class] << " dropdown-item"

    link_to(title, url, options)
  end

  def nav_link(link_text, link_path, options)
    controller  = options.fetch(:controller) { "" }
    icon        = options.fetch(:icon) { nil }
    class_names = ["nav-link"]

    class_names << "active" if link_path == request.path || controller.include?(controller_name)

    link_to(link_path, class: class_names.join(" ")) do
      [tag.i(class: "fas fa-#{icon}"), link_text].join(" ").html_safe
    end
  end
end
