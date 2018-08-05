require "rails_helper"

RSpec.describe Filter::Params::CalloutParticipation do
  describe "#callout_filter_params" do
    it "returns the specified parameters or default parameters from the account settings" do
      account = account_with_settings("callout_filter_params" => { "status" => "running" })

      filter_params = described_class.new(account: account, callout_filter_params: {})
      default_filter_params = described_class.new(account: account)

      expect(filter_params.callout_filter_params).to eq({})
      expect(default_filter_params.callout_filter_params).to eq("status" => "running")
    end
  end

  describe "#callout_participation_filter_params" do
    it "returns the specified parameters or default parameters from the account settings" do
      account = account_with_settings(
        "callout_participation_filter_params" => { "having_max_phone_calls_count" => "3" }
      )

      filter_params = described_class.new(account: account, callout_participation_filter_params: {})
      default_filter_params = described_class.new(account: account)

      expect(filter_params.callout_participation_filter_params).to eq({})
      expect(
        default_filter_params.callout_participation_filter_params
      ).to eq("having_max_phone_calls_count" => "3")
    end
  end

  def account_with_settings(settings = {})
    build_stubbed(
      :account, settings: { "batch_operation_phone_call_create_parameters" => settings }
    )
  end
end
