module DashboardHelper
  def nav_link(link_text, link_path, controllers)
    class_names = ["nav-link"]
    class_names << "active" if controllers.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to(link_text, link_path, class: class_names.join(" "))
    end
  end

  def link_to_add_metadata_fields(name, f, partial_path)
    new_object = MetadataForm.new
    fields = f.simple_fields_for(
      :metadata_forms, [new_object], child_index: "new_metadata_forms"
    ) do |builder|
      render(
        partial: partial_path,
        locals: { f: builder }
      )
    end

    link_to(
      name, "#", class: "js-add-metadata-fields",
                 data: { association: "metadata_forms", blueprint: fields.to_s }
    )
  end

  def all_provices
    Pumi::Province.all
  end

  def province_names(ids)
    provinces = Pumi::Province.all.select { |p| ids.include? p.id }
    provinces.map(&:name_en).join(', ')
  end

  def province_name(id)
    province = Pumi::Province.find_by_id(id)
    province ? province.name_en : '-'
  end

  def district_name(id)
    district = Pumi::District.find_by_id(id)
    district ? district.name_en : '-'
  end

  def commune_name(id)
    commune = Pumi::Commune.find_by_id(id)
    commune ? commune.name_en : '-'
  end

  def village_name(id)
    village = Pumi::Village.find_by_id(id)
    village ? village.name_en : '-'
  end
end
