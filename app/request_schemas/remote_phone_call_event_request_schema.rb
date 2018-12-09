RemotePhoneCallEventRequestSchema = Dry::Validation.Params(ApplicationRequestSchema) do
  required(:CallSid, :string).filled(:str?)
  required(:From, :string).filled(:str?)
  required(:To, :string).filled(:str?)
  required(:Direction, :string).filled(:str?)
  required(:CallStatus, :string).filled(:str?)
  required(:AccountSid, :string).filled(:str?)
  optional(:ApiVersion, :string).filled(eql?: "2010-04-01")
  optional(:CallDuration, :integer).filled(:int?)
  optional(:Digits, :integer).filled(:int?)
end
