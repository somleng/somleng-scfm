class CallFlowLogic::Simulation < CallFlowLogic::PlayMessage
  FROM_NUMBER = "999999".freeze

  def remote_request_params
    super.merge("from" => FROM_NUMBER)
  end
end
