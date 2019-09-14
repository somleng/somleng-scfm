require "rails_helper"

RSpec.describe RemotePhoneCallEventRequestSchema, type: :request_schema do
  it { expect(validate_schema(CallSid: nil)).not_to have_valid_field(:CallSid) }
  it { expect(validate_schema(CallSid: SecureRandom.uuid)).to have_valid_field(:CallSid) }

  it { expect(validate_schema(To: nil)).not_to have_valid_field(:To) }
  it { expect(validate_schema(To: "+855 97 2345 678")).to have_valid_field(:To) }

  it { expect(validate_schema(From: nil)).not_to have_valid_field(:From) }
  it { expect(validate_schema(From: "+855 97 2345 678")).to have_valid_field(:From) }

  it { expect(validate_schema(Direction: nil)).not_to have_valid_field(:Direction) }
  it { expect(validate_schema(Direction: "inbound")).to have_valid_field(:Direction) }
  it { expect(validate_schema(Direction: "outbound-api")).to have_valid_field(:Direction) }

  it { expect(validate_schema(CallStatus: nil)).not_to have_valid_field(:CallStatus) }
  it { expect(validate_schema(CallStatus: "in-progress")).to have_valid_field(:CallStatus) }

  it { expect(validate_schema(AccountSid: nil)).not_to have_valid_field(:AccountSid) }
  it { expect(validate_schema(AccountSid: SecureRandom.uuid)).to have_valid_field(:AccountSid) }

  it { expect(validate_schema(CallDuration: nil)).not_to have_valid_field(:CallDuration) }
  it { expect(validate_schema(CallDuration: "foo")).not_to have_valid_field(:CallDuration) }
  it { expect(validate_schema({})).to have_valid_field(:CallDuration) }
  it { expect(validate_schema(CallDuration: "11")).to have_valid_field(:CallDuration) }

  it { expect(validate_schema(ApiVersion: nil)).not_to have_valid_field(:ApiVersion) }
  it { expect(validate_schema(ApiVersion: "foo")).not_to have_valid_field(:ApiVersion) }
  it { expect(validate_schema({})).to have_valid_field(:ApiVersion) }
  it { expect(validate_schema(ApiVersion: "2010-04-01")).to have_valid_field(:ApiVersion) }

  it { expect(validate_schema(Digits: nil)).not_to have_valid_field(:Digits) }
  it { expect(validate_schema(Digits: "foo")).not_to have_valid_field(:Digits) }
  it { expect(validate_schema({})).to have_valid_field(:Digits) }
  it { expect(validate_schema(ApiVersion: "5")).to have_valid_field(:Digits) }
end
