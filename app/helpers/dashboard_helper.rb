module DashboardHelper
  def batch_operation_create_phone_calls_default_filter_params
    default_batch_operation_filter_params = current_account.settings["batch_operation_phone_call_create_parameters"] || {}
    callout_participation_filter_params = default_batch_operation_filter_params["callout_participation_filter_params"] || {}
    callout_filter_params = default_batch_operation_filter_params.slice("callout_filter_params")
    callout_participation_filter_params.merge(callout_filter_params).presence
  end
end
