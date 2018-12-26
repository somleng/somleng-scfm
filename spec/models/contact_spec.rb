require "rails_helper"

RSpec.describe Contact do
  let(:factory) { :contact }

  include_examples "has_metadata"

  describe "validations" do
    it { is_expected.to validate_presence_of(:msisdn) }
    it { is_expected.to allow_value(generate(:somali_msisdn)).for(:msisdn) }
    it { is_expected.not_to allow_value("252123456").for(:msisdn) }
    it { is_expected.to allow_value("+252 66-(2)-345-678").for(:msisdn) }
  end

  describe "associations" do
    it { is_expected.to have_many(:callout_participations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:phone_calls).dependent(:restrict_with_error) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:call_flow_logic).to(:account) }
  end
end
