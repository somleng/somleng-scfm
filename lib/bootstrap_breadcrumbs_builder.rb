class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::SimpleBuilder
  def initialize(context, elements, options = {})
    super

    @options[:separator] = ""
  end

  def render_element(element)
    if element.path.nil?
      content = compute_name(element)
    else
      content = @context.link_to_unless_current(compute_name(element), compute_path(element), element.options)
    end

    @context.content_tag(:li, content, class: "breadcrumb-item")
  end
end
