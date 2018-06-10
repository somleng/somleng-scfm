module SystemSpecHelpers
  def click_action_button(action, key: nil, type: nil, namespace: nil, **interpolations)
    type ||= :button
    key ||= :actions
    namespace ||= :titles
    public_send("click_#{type}", I18n.translate!(:"#{namespace}.#{key}.#{action}", interpolations))
  end

  def fill_in_key_values_for(attribute, with:)
    with.each_with_index do |(key, value), index|
      fill_in_key_value_for(
        attribute,
        with: { key: key, value: value },
        index: index
      )
      add_key_value_for(attribute)
    end
  end

  def fill_in_key_value_for(attribute, with:, index: 0)
    within("##{attribute}_fields") do
      page.all("input[placeholder='Key']")[index].set(with[:key]) if with.key?(:key)
      page.all("input[placeholder='Value']")[index].set(with[:value]) if with.key?(:value)
    end
  end

  def remove_key_value_for(attribute, index: 0)
    within("##{attribute}_fields") do
      page.all(:xpath, "//a[text()[contains(.,'Remove')]]")[index].click
    end
  end

  def add_key_value_for(attribute)
    within("##{attribute}_fields") do
      click_link("Add")
    end
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
      find("div.selectize-input").click
      find("div[data-selectable]", text: text).click
    end
  end

  def remove_uploaded_files
    FileUtils.rm_rf("#{Rails.root}/tmp/storage_test")
  end

  def have_content_tag_for(model, model_name: nil)
    have_selector("##{model_name || model.class.to_s.underscore.tr('/', '_')}_#{model.id}")
  end

  def have_sortable_column(column)
    have_css("a.sortable##{column}")
  end
end

RSpec.configure do |config|
  config.include(SystemSpecHelpers, type: :system)
end
