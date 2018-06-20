class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::SimpleBuilder
  def initialize(context, elements, options = {})
    super

    @options[:separator] = ""
  end

  def render_element(element)
    if element.path.nil?
      content = compute_name(element)
    else
      breadcrumb_path = compute_path(element)
      content = @context.link_to_unless_current(compute_name(element), breadcrumb_path, element.options)
      active = @context.current_page?(breadcrumb_path)
    end

    html_options = {}
    breadcrumb_item_classes = ["breadcrumb-item"]

    if active
      html_options[:"aria-current"] = "page"
      breadcrumb_item_classes << "active"
    end

    html_options[:class] = breadcrumb_item_classes.join(" ")

    @context.content_tag(:li, content, html_options)
  end
end
