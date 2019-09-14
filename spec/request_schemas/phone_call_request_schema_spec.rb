require "rails_helper"

RSpec.describe PhoneCallRequestSchema, type: :request_schema do
  it "validates the msisdn" do
    expect(validate_schema(msisdn: nil)).not_to have_valid_field(:msisdn)
    expect(validate_schema({})).to have_valid_field(:msisdn)
    expect(
      validate_schema(msisdn: "+855 97 2345 6789")
    ).not_to have_valid_field(:msisdn)
  end

  it "validates the call flow logic" do
    expect(
      validate_schema(call_flow_logic: nil)
    ).not_to have_valid_field(:call_flow_logic)
    expect(
      validate_schema({})
    ).to have_valid_field(:call_flow_logic)
    expect(
      validate_schema(call_flow_logic: "User")
    ).not_to have_valid_field(:call_flow_logic)
    expect(
      validate_schema(call_flow_logic: "CallFlowLogic::HelloWorld")
    ).to have_valid_field(:call_flow_logic)
  end

  it "validates the remote request params" do
    expect(
      validate_schema(remote_request_params: nil)
    ).not_to have_valid_field(:remote_request_params)
    expect(
      validate_schema({})
    ).to have_valid_field(:remote_request_params)
    expect(
      validate_schema(remote_request_params: { "foo" => "bar" })
    ).not_to have_valid_field(:remote_request_params)
    expect(
      validate_schema(remote_request_params: "foo")
    ).not_to have_valid_field(:remote_request_params)
    expect(
      validate_schema(remote_request_params: generate(:twilio_request_params))
    ).to have_valid_field(:remote_request_params)
  end
end
