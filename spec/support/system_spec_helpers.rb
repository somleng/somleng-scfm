module SystemSpecHelpers
  def click_action_button(action, key: nil, type: nil, namespace: nil, **interpolations)
    type ||= :button
    key ||= :actions
    namespace ||= :titles
    public_send("click_#{type}", I18n.translate!(:"#{namespace}.#{key}.#{action}", interpolations))
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

  def have_content_tag_for(model, model_name: nil)
    have_selector("##{model_name || model.class.to_s.underscore.tr('/', '_')}_#{model.id}")
  end

  def create_callout_participation(account:, **options)
    callout = options.delete(:callout) || create(:callout, account: account)
    contact = options.delete(:contact) || create(:contact, account: account)
    create(:callout_participation, { callout: callout, contact: contact }.merge(options))
  end

  def create_phone_call(account:, **options)
    callout_participation = options.delete(:callout_participation) || create_callout_participation(
      account: account
    )
    create(:phone_call, { callout_participation: callout_participation }.merge(options))
  end
end

RSpec.configure do |config|
  config.include(SystemSpecHelpers, type: :system)
end
