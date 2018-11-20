class StartRapidproFlowJob < ApplicationJob
  def perform(phone_call)
    StartRapidproFlow.new(phone_call).call
  end
end
