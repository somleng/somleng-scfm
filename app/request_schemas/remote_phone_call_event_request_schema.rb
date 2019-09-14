class RemotePhoneCallEventRequestSchema < ApplicationRequestSchema
  params do
    required(:CallSid).filled(:string)
    required(:From).filled(:string)
    required(:To).filled(:string)
    required(:Direction).filled(:string)
    required(:CallStatus).filled(:string)
    required(:AccountSid).filled(:string)
    optional(:ApiVersion).filled(:string, eql?: "2010-04-01")
    optional(:CallDuration).filled(:integer)
    optional(:Digits).filled(:integer)
  end
end
