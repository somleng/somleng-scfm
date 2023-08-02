require "rails_helper"

RSpec.describe RemotePhoneCallEventRequestSchema, type: :request_schema do
  it { expect(validate_schema(input_params: { CallSid: nil })).not_to have_valid_field(:CallSid) }
  it { expect(validate_schema(input_params: { CallSid: SecureRandom.uuid })).to have_valid_field(:CallSid) }

  it { expect(validate_schema(input_params: { To: nil })).not_to have_valid_field(:To) }
  it { expect(validate_schema(input_params: { To: "+855 97 2345 678" })).to have_valid_field(:To) }

  it { expect(validate_schema(input_params: { From: nil })).not_to have_valid_field(:From) }
  it { expect(validate_schema(input_params: { From: "+855 97 2345 678" })).to have_valid_field(:From) }

  it { expect(validate_schema(input_params: { Direction: nil })).not_to have_valid_field(:Direction) }
  it { expect(validate_schema(input_params: { Direction: "inbound" })).to have_valid_field(:Direction) }
  it { expect(validate_schema(input_params: { Direction: "outbound-api" })).to have_valid_field(:Direction) }

  it { expect(validate_schema(input_params: { CallStatus: nil })).not_to have_valid_field(:CallStatus) }
  it { expect(validate_schema(input_params: { CallStatus: "in-progress" })).to have_valid_field(:CallStatus) }

  it { expect(validate_schema(input_params: { AccountSid: nil })).not_to have_valid_field(:AccountSid) }
  it { expect(validate_schema(input_params: { AccountSid: SecureRandom.uuid })).to have_valid_field(:AccountSid) }

  it { expect(validate_schema(input_params: { CallDuration: nil })).not_to have_valid_field(:CallDuration) }
  it { expect(validate_schema(input_params: { CallDuration: "foo" })).not_to have_valid_field(:CallDuration) }
  it { expect(validate_schema(input_params: {})).to have_valid_field(:CallDuration) }
  it { expect(validate_schema(input_params: { CallDuration: "11" })).to have_valid_field(:CallDuration) }

  it { expect(validate_schema(input_params: { ApiVersion: nil })).not_to have_valid_field(:ApiVersion) }
  it { expect(validate_schema(input_params: { ApiVersion: "foo" })).not_to have_valid_field(:ApiVersion) }
  it { expect(validate_schema(input_params: {})).to have_valid_field(:ApiVersion) }
  it { expect(validate_schema(input_params: { ApiVersion: "2010-04-01" })).to have_valid_field(:ApiVersion) }

  it { expect(validate_schema(input_params: { Digits: nil })).not_to have_valid_field(:Digits) }
  it { expect(validate_schema(input_params: { Digits: "foo" })).not_to have_valid_field(:Digits) }
  it { expect(validate_schema(input_params: {})).to have_valid_field(:Digits) }
  it { expect(validate_schema(input_params: { ApiVersion: "5" })).to have_valid_field(:Digits) }

  def validate_schema(...)
    RemotePhoneCallEventRequestSchema.new(...)
  end
end
