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
      id: resource && resource.id,
      default: :"titles.app_name"
    )
  end

  def related_link_to(title, url, options = {})
    options[:class] ||= ""
    options[:class] << " dropdown-item"

    link_to(title, url, options)
  end
end
