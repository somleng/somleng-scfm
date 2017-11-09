require_relative "setup_scenario"

module ActiveJobHelpers
  include ActiveJob::TestHelper

  def setup_scenario
    super
    clear_enqueued_jobs
  end
end

RSpec.configure do |config|
  config.include(ActiveJobHelpers)
end
