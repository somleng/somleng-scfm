module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-danger"
    when :alert then "alert alert-danger"
    end
  end

  def title
    translate(
      :"titles.#{controller_name}.#{action_name}",
      id: defined?(resource) && resource && resource.id,
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
    turbolinks  = options.fetch(:turbolinks) { true }
    class_names = ["nav-link"]

    class_names << "active" if link_path == request.path || controller.include?(controller_name)

    link_to(link_path, class: class_names.join(" "), data: { turbolinks: turbolinks }) do
      fa_icon(icon, text: link_text)
    end
  end
end
