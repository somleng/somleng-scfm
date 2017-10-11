class StartFlowRapidproTask < ApplicationTask
  DEFAULT_MAX_FLOWS_TO_START = 1
  RAPIDPRO_FLOW_ID_KEY = "rapidpro_flow_id"
  RAPIDPRO_FLOW_STARTED_AT_KEY = "rapidpro_flow_started_at"

  class Install < ApplicationTask::Install
    DEFAULT_ENV_VARS = {
      :start_flow_rapidpro_task_max_flows_to_start => "100",
      :start_flow_rapidpro_task_remote_request_params => "{\"flow\"=>\"flow-id\", \"groups\"=>[], \"contacts\"=>[], \"urns\"=>[\"telegram:telegram-id\"], \"extra\"=>{}}",
      :rapidpro_base_url => "https://app.rapidpro.io/api",
      :rapidpro_api_version => "v2",
      :rapidpro_api_token => "replace-me-rapidpro-api-token"
    }

    def self.default_env_vars(task_name)
      super.merge(DEFAULT_ENV_VARS)
    end
  end

  def run!
    phone_calls_to_start_flow.includes(:callout_participation).limit(num_flows_to_start).find_each do |phone_call|
      begin
        mark_flow_as_started!(phone_call)
        start_flow!(phone_call)
      rescue ActiveRecord::StaleObjectError
      end
    end
  end

  private

  def phone_calls_to_start_flow
    PhoneCall.from_running_callout.completed.metadata_has_value(
      RAPIDPRO_FLOW_STARTED_AT_KEY, nil
    )
  end

  def mark_flow_as_started!(phone_call)
    phone_call.metadata[RAPIDPRO_FLOW_STARTED_AT_KEY] = Time.now
    phone_call.save!
  end

  def start_flow!(phone_call)
    response = rapidpro_client.start_flow!(
      default_start_flow_rapidpro_request_params.merge(
        start_flow_rapidpro_request_params(phone_call)
      )
    )
    phone_call.metadata[RAPIDPRO_FLOW_ID_KEY] = response["id"]
    phone_call.save!
  end

  def start_flow_rapidpro_request_params(phone_call)
    {} # Dynamically override default params here
  end

  def num_flows_to_start
    max_flows_to_start
  end

  def max_flows_to_start
    (ENV["START_FLOW_RAPIDPRO_TASK_MAX_FLOWS_TO_START"].presence || DEFAULT_MAX_FLOWS_TO_START).to_i
  end

  def default_start_flow_rapidpro_request_params
    @default_start_flow_rapidpro_request_params ||= JSON.parse(ENV["START_FLOW_RAPIDPRO_TASK_REMOTE_REQUEST_PARAMS"] || "{}")
  end

  def rapidpro_client
    @rapidpro_client ||= Rapidpro::Client.new
  end
end
