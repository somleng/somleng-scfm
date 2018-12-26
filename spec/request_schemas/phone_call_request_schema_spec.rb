require "rails_helper"

RSpec.describe PhoneCallRequestSchema, type: :request_schema do
  it { expect(validate_schema(msisdn: nil)).not_to have_valid_field(:msisdn) }
  it { expect(validate_schema).to have_valid_field(:msisdn) }
  it { expect(validate_schema(msisdn: "+855 97 2345 6789")).not_to have_valid_field(:msisdn) }

  it { expect(validate_schema(call_flow_logic: nil)).not_to have_valid_field(:call_flow_logic) }
  it { expect(validate_schema).to have_valid_field(:call_flow_logic) }
  it { expect(validate_schema(call_flow_logic: "User")).not_to have_valid_field(:call_flow_logic) }
  it { expect(validate_schema(call_flow_logic: "CallFlowLogic::HelloWorld")).to have_valid_field(:call_flow_logic) }

  it { expect(validate_schema(remote_request_params: nil)).not_to have_valid_field(:remote_request_params) }
  it { expect(validate_schema).to have_valid_field(:remote_request_params) }
  it { expect(validate_schema(remote_request_params: { "foo" => "bar" })).not_to have_valid_field(:remote_request_params) }
  it { expect(validate_schema(remote_request_params: "foo")).not_to have_valid_field(:remote_request_params) }
  it { expect(validate_schema(remote_request_params: generate(:twilio_request_params))).to have_valid_field(:remote_request_params) }

  it { expect(validate_schema(metadata: nil)).not_to have_valid_field(:metadata) }
  it { expect(validate_schema).to have_valid_field(:metadata) }
  it { expect(validate_schema(metadata: { "foo" => "bar" })).to have_valid_field(:metadata) }

  it { expect(validate_schema(metadata_merge_mode: nil)).not_to have_valid_field(:metadata_merge_mode) }
  it { expect(validate_schema(metadata_merge_mode: "foo")).not_to have_valid_field(:metadata_merge_mode) }
  it { expect(validate_schema).to have_valid_field(:metadata_merge_mode) }
  it { expect(validate_schema(metadata_merge_mode: "replace")).to have_valid_field(:metadata_merge_mode) }
end
