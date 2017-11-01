module SetupScenario
  def setup_scenario
  end
end

RSpec.configure do |config|
  config.include(SetupScenario)
  config.before do
    setup_scenario
  end
end
