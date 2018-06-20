module DashboardHelper
  def nav_link(link_text, link_path, controller_names:, icon:)
    class_names = ["nav-link"]
    class_names << "active" if controller_names.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to(link_path, class: class_names.join(" ")) do
        fa_icon(icon, text: link_text)
      end
    end
  end
end
