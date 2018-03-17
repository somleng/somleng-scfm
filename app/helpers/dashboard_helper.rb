module DashboardHelper
  def nav_link(link_text, link_path, controllers)
    class_name = 'nav-link'
    class_name += controllers.include?(controller_name) ? ' active' : ''

    content_tag(:li, class: 'nav-item') do
      link_to link_text, link_path, class: class_name
    end
  end
end
