module DashboardHelper
  def nav_link(link_text, link_path, controllers, count)
    class_names = ["nav-link"]
    class_names << "active" if controllers.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to(link_path, class: class_names.join(" ")) do
        (link_text + " (#{count})").html_safe
      end
    end
  end
end
