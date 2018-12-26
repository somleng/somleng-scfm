PhoneCallRequestSchema = Dry::Validation.Params(ApplicationRequestSchema) do
  optional(:msisdn, ApplicationRequestSchema::Types::PhoneNumber).filled(:phone_number?)
  optional(:call_flow_logic, :string).filled(:call_flow_logic?)
  optional(:remote_request_params, :hash).filled(:hash?, :remote_request_params?)
  optional(:metadata_merge_mode, :string).filled(:str?, included_in?: metadata_merge_modes)
  optional(:metadata, :hash).filled(:hash?)
end
