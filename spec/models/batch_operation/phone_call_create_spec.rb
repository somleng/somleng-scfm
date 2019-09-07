require "rails_helper"

RSpec.describe BatchOperation::PhoneCallCreate do
  let(:factory) { :phone_call_create_batch_operation }

  describe "validations" do
    context "remote_request_params" do
      subject { build(factory, remote_request_params: {}) }
      it { is_expected.not_to allow_value("foo" => "bar").for(:remote_request_params) }
      it { is_expected.to validate_presence_of(:remote_request_params) }
    end

    it "validates presence of callout participations" do
      batch_operation = create(:phone_call_create_batch_operation)
      batch_operation.skip_validate_preview_presence = nil

      expect(batch_operation).not_to be_valid
      expect(batch_operation.errors[:callout_participations_preview]).not_to be_empty

      batch_operation.skip_validate_preview_presence = true

      expect(batch_operation).to be_valid

      batch_operation.skip_validate_preview_presence = nil
      create_callout_participation(account: batch_operation.account)

      expect(batch_operation).to be_valid
    end
  end

  describe "#parameters" do
    it "can set the parameters from the account settings" do
      account = build_stubbed(
        :account,
        settings: {
          "batch_operation_phone_call_create_parameters" => {
            "callout_filter_params" => {
              "status" => "running"
            }
          }
        }
      )
      batch_operation = described_class.new(account: account)

      batch_operation.valid?

      expect(batch_operation.parameters).to eq(
        account.settings.fetch("batch_operation_phone_call_create_parameters")
      )
    end
  end

  include_examples("batch_operation")
  include_examples("hash_store_accessor", :remote_request_params)
  include_examples("phone_call_operation_batch_operation")

  describe "#run!" do
    it "creates phone calls in a random order" do
      batch_operation = nil
      callout_participations = []
      applied_callout_participations = []

      100.times do
        batch_operation = create(:phone_call_create_batch_operation)
        callout_participations = create_callout_participations(account: batch_operation.account)

        batch_operation.run!

        applied_callout_participations = batch_operation.phone_calls.order(
          :created_at
        ).map(&:callout_participation)

        break unless applied_callout_participations == callout_participations
      end

      expect(applied_callout_participations).to match_array(callout_participations)
      expect(applied_callout_participations).not_to eq(callout_participations)
      expect(batch_operation.phone_calls.size).to eq(callout_participations.size)
      created_phone_call = batch_operation.reload.phone_calls.first!
      expect(created_phone_call.remote_request_params).to eq(batch_operation.remote_request_params)
    end
  end

  describe "#callout_participations_preview" do
    it "selects callout participations in a random order" do
      batch_operation = create(:phone_call_create_batch_operation)
      callout_participations = create_callout_participations(account: batch_operation.account)

      results = []
      100.times do
        results = batch_operation.callout_participations_preview
        break results unless results == callout_participations
      end

      expect(results).to match_array(callout_participations)
      expect(results).not_to eq(callout_participations)
    end
  end

  def create_callout_participations(account:)
    results = []
    2.times do
      results << create_callout_participation(account: account)
    end
    results
  end
end
