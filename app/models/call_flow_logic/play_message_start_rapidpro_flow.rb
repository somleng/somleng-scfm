module CallFlowLogic
  class PlayMessageStartRapidproFlow < CallFlowLogic::PlayMessage
    def run!
      super
      return unless event.phone_call.completed?

      ExecuteWorkflowJob.perform_later(StartRapidproFlow.to_s, event.phone_call)
    end
  end
end
