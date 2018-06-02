module DashboardHelper
  def nav_link(link_text, link_path, controllers)
    class_names = ["nav-link"]
    class_names << "active" if controllers.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to(link_text, link_path, class: class_names.join(" "))
    end
  end

  def location_names(ids, type)
    locations = "pumi/#{type}".camelize.constantize.all.map do |location|
      next if Array(ids).exclude? location.id
      "#{location.name_en} (#{location.name_km})"
    end

    Array(locations).reject(&:blank?).join(", ")
  end
end
