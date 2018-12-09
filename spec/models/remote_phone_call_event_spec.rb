require "rails_helper"

RSpec.describe RemotePhoneCallEvent do
  let(:factory) { :remote_phone_call_event }

  include_examples "has_metadata"
  include_examples("has_call_flow_logic")

  describe "associations" do
    it { is_expected.to belong_to(:phone_call).validate(true).autosave(true) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:callout).to(:phone_call) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:call_flow_logic) }
    it { is_expected.to validate_presence_of(:remote_call_id) }
    it { is_expected.to validate_presence_of(:remote_direction) }
  end
end
