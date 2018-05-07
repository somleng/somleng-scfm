module SystemSpecHelpers
  def click_action_button(action, key: nil, type: nil)
    type ||= :button
    key ||= :actions
    public_send("click_#{type}", I18n.translate!(:"titles.#{key}.#{action}"))
  end

  def have_link_to_action(action, key: nil, href: nil)
    key ||= :actions
    have_link(
      I18n.translate!(:"titles.#{key}.#{action}"),
      { href: href }.compact
    )
  end

  def have_record(record)
    name = record.class.name.downcase
    have_selector("##{name}_#{record.id}")
  end

  def include_location(name)
    location = Pumi::Province.where(name_en: name).first
    include(location.id)
  end

  # http://climber2002.github.io/blog/2014/09/22/capybara-integration-tests-with-jquery-selectize/
  def select_selectize(id, text)
    within(id) do
      first("div.selectize-input").click
      find("div[data-selectable]", text: text).click
      execute_script("document.activeElement.blur()")
    end
  end
end

RSpec.configure do |config|
  config.include(SystemSpecHelpers, type: :system)
end
