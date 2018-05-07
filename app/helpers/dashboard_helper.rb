module DashboardHelper
  def nav_link(link_text, link_path, controllers)
    class_names = ["nav-link"]
    class_names << "active" if controllers.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to(link_text, link_path, class: class_names.join(" "))
    end
  end

  def all_provices
    Pumi::Province.all
  end

  def province_names(ids)
    provinces = Pumi::Province.all.select { |p| ids.include? p.id }
    provinces.map(&:name_en).join(', ')
  end
end
