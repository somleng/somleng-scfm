module SystemSpecHelpers
  def click_action_button(action, key: nil, type: nil)
    type ||= :button
    key ||= :actions
    public_send("click_#{type}", I18n.translate!(:"titles.#{key}.#{action}"))
  end

  def fill_in_metadata(with:)
    within("#metadata_fields") do
      fill_in("Key", with: with[:key]) if with.key?(:key)
      fill_in("Value", with: with[:value]) if with.key?(:value)
    end
  end

  def have_link_to_action(action, key: nil, href: nil)
    key ||= :actions
    have_link(
      I18n.translate!(:"titles.#{key}.#{action}"),
      { href: href }.compact
    )
  end
end

RSpec.configure do |config|
  config.include(SystemSpecHelpers, type: :system)
end
