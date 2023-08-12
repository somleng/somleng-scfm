module SystemSpecHelpers
  def fill_in_key_values_for(attribute, with:)
    with.each_with_index do |(key, value), index|
      fill_in_key_value_for(
        attribute,
        with: { key:, value: },
        index:
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

  def have_content_tag_for(model, model_name: nil)
    have_selector("##{model_name || model.class.to_s.underscore.tr('/', '_')}_#{model.id}")
  end
end

RSpec.configure do |config|
  config.include(SystemSpecHelpers, type: :system)
end
