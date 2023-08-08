module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-danger"
    when :alert then "alert alert-danger"
    end
  end

  def page_title(title:, subtitle: nil, &block)
    content_for(:page_title, title)

    content_tag(:div, class: "card-header d-flex justify-content-between align-items-center") do
      content = "".html_safe
      content += content_tag(:span, title, class: "h2")

      if subtitle.present?
        content += " "
        content += content_tag(:small, subtitle)
      end

      if block_given?
        content += content_tag(:div, id: "page_actions", class: "card-header-actions") do
          capture(&block)
        end
      end

      content
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

  def sidebar_nav(text, path, icon_class:, link_options: {})
    content_tag(:li, class: "nav-item") do
      sidebar_nav_class = "nav-link"
      sidebar_nav_class += " active" if request.path == path
      link_to(path, class: sidebar_nav_class, **link_options) do
        content = "".html_safe
        content += content_tag(:i, nil, class: "nav-icon #{icon_class}")
        content + " " + text
      end
    end
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end
end
