module DashboardHelper
  def nav_link(link_text, link_path, controllers)
    class_names = ["nav-link"]
    class_names << "active" if controllers.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to(link_text, link_path, class: class_names.join(" "))
    end
  end

  def location_names(province_ids, type)
    Array(province_ids).map do |location_id|
      location = type.find_by_id(location_id)
      "#{location.name_km} (#{location.name_en})"
    end.join(", ")
  end
end
