module DashboardHelper
  def nav_link(link_text, link_path, controllers)
    class_name = 'nav-link'
    class_name += controllers.include?(controller_name) ? ' active' : ''

    content_tag(:li, class: 'nav-item') do
      link_to link_text, link_path, class: class_name
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
      data: { association: 'metadata_forms', blueprint: "#{fields}" }
    )
  end
end
