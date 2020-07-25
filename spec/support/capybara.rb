require "selenium/webdriver"

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test

    Capybara.server = :puma, { Silent: true }
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  config.before(:each, type: :system, selenium_chrome: true) do
    driven_by :selenium, using: :chrome
  end

  config.after(:each, type: :system, js: true) do
    errors = page.driver.browser.manage.logs.get(:browser)
    if errors.present?
      message = errors.map(&:message).join("\n")
      puts message
    end
  end
end
