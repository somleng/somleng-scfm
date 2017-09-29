class StartFlowRapidproTask < ApplicationTask
  DEFAULT_MAX_FLOWS_TO_START = 1
  RAPIDPRO_FLOW_ID_KEY = "rapidpro_flow_id"
  RAPIDPRO_FLOW_STARTED_AT_KEY = "rapidpro_flow_started_at"

  def run!
    PhoneCall.completed.metadata_has_value(RAPIDPRO_FLOW_STARTED_AT_KEY, nil).limit(num_flows_to_start).find_each do |phone_call|
      begin
        mark_flow_as_started!(phone_call)
        start_flow!(phone_call)
      rescue ActiveRecord::StaleObjectError
      end
    end
  end

  private

  def mark_flow_as_started!(phone_call)
    phone_call.metadata[RAPIDPRO_FLOW_STARTED_AT_KEY] = Time.now
    phone_call.save!
  end

  def start_flow!(phone_call)
    response = rapidpro_client.start_flow!(start_flow_rapidpro_params)
    phone_call.metadata[RAPIDPRO_FLOW_ID_KEY] = response["id"]
    phone_call.save!
  end

  def num_flows_to_start
    max_flows_to_start
  end

  def max_flows_to_start
    (ENV["START_FLOW_RAPIDPRO_TASK_MAX_FLOWS_TO_START"] || DEFAULT_MAX_FLOWS_TO_START).to_i
  end

  def start_flow_rapidpro_params
    @start_flow_rapidpro_params ||= JSON.parse(ENV["START_FLOW_RAPIDPRO_TASK_REMOTE_REQUEST_PARAMS"] || "{}")
  end

  def rapidpro_client
    @rapidpro_client ||= Rapidpro::Client.new
  end
end
