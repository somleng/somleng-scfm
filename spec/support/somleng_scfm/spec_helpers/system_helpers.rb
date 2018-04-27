require_relative "../spec_helpers"

module SomlengScfm::SpecHelpers::SystemHelpers
  def select2_select(label_text, options = {})
    find('label', text: label_text).sibling('.select2-container').click
    find('.select2-search__field').send_keys(options.fetch(:with, ""), :enter)
  end
end
