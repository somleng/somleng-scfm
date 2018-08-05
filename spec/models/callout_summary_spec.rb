require "rails_helper"

RSpec.describe CalloutSummary do
  describe "#participations" do
    it "returns the number of callout participations" do
      callout = create(:callout)
      create_callout_participation(
        account: callout.account, callout: callout
      )
      callout_summary = described_class.new(callout)

      result = callout_summary.participations

      expect(result).to eq(1)
    end
  end

  describe "#participations_still_to_be_called" do
    it "returns the number of callout participations still to be called" do
      account = account_with_settings(
        "callout_filter_params" => { "status" => "running" },
        "callout_participation_filter_params" => { "no_phone_calls_or_last_attempt" => "failed" }
      )
      # assert that the callout filter params are ignored
      callout = create(:callout, account: account, status: Callout::STATE_PAUSED)
      create_phone_call_for_callout(callout, status: PhoneCall::STATE_COMPLETED)
      create_phone_call_for_callout(callout, status: PhoneCall::STATE_FAILED)
      callout_summary = described_class.new(callout)

      result = callout_summary.participations_still_to_be_called

      expect(result).to eq(1)
    end
  end

  describe "#completed_calls" do
    it "returns the number of calls" do
      callout = create(:callout)
      create_phone_call_for_callout(callout, status: PhoneCall::STATE_COMPLETED)
      create_phone_call_for_callout(callout)
      callout_summary = described_class.new(callout)

      result = callout_summary.completed_calls

      expect(result).to eq(1)
    end
  end

  describe "#not_answered_calls" do
    it "returns the number of calls" do
      callout = create(:callout)
      create_phone_call_for_callout(callout, status: PhoneCall::STATE_NOT_ANSWERED)
      create_phone_call_for_callout(callout)
      callout_summary = described_class.new(callout)

      result = callout_summary.not_answered_calls

      expect(result).to eq(1)
    end
  end

  describe "#busy_calls" do
    it "returns the number of calls" do
      callout = create(:callout)
      create_phone_call_for_callout(callout, status: PhoneCall::STATE_BUSY)
      create_phone_call_for_callout(callout)
      callout_summary = described_class.new(callout)

      result = callout_summary.busy_calls

      expect(result).to eq(1)
    end
  end

  describe "#failed_calls" do
    it "returns the number of calls" do
      callout = create(:callout)
      create_phone_call_for_callout(callout, status: PhoneCall::STATE_FAILED)
      create_phone_call_for_callout(callout)
      callout_summary = described_class.new(callout)

      result = callout_summary.failed_calls

      expect(result).to eq(1)
    end
  end

  describe "#errored_calls" do
    it "returns the number of calls" do
      callout = create(:callout)
      create_phone_call_for_callout(callout, status: PhoneCall::STATE_ERRORED)
      create_phone_call_for_callout(callout)
      callout_summary = described_class.new(callout)

      result = callout_summary.errored_calls

      expect(result).to eq(1)
    end
  end

  def account_with_settings(settings = {})
    create(:account, settings: { "batch_operation_phone_call_create_parameters" => settings })
  end

  def create_phone_call_for_callout(callout, attributes = {})
    callout_participation = create_callout_participation(account: callout.account, callout: callout)
    create_phone_call(account: callout.account, callout_participation: callout_participation, **attributes)
  end
end
