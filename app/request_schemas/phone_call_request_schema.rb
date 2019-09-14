class PhoneCallRequestSchema < MetadataRequestSchema
  params do
    optional(:msisdn).filled(:string)
    optional(:call_flow_logic).filled(:string)
    optional(:remote_request_params).filled(:hash?)
  end

  rule(:msisdn).validate(:phone_number_format)

  rule(:call_flow_logic) do
    key.failure("is invalid") unless CallFlowLogicModel.new(call_flow_logic: value).valid?
  end

  rule(:remote_request_params) do
    key.failure("is invalid") unless RemoteRequestParamsModel.new(remote_request_params: value).valid?
  end

  class CallFlowLogicModel
    include ActiveModel::Model

    attr_accessor :call_flow_logic

    validates :call_flow_logic, call_flow_logic: true
  end

  class RemoteRequestParamsModel
    include ActiveModel::Model

    attr_accessor :remote_request_params

    validates :remote_request_params, twilio_request_params: true
  end
end
