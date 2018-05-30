require "rails_helper"

RSpec.describe BatchOperation::PhoneCallCreate do
  let(:factory) { :phone_call_create_batch_operation }

  describe "associations" do
    it { is_expected.to have_many(:callout_participations) }
    it { is_expected.to have_many(:contacts) }
  end

  describe "validations" do
    context "remote_request_params" do
      subject { build(factory, remote_request_params: {}) }
      it { is_expected.not_to allow_value("foo" => "bar").for(:remote_request_params) }
      it { is_expected.to validate_presence_of(:remote_request_params) }
    end

    it "validates presence of callout participations" do
      batch_operation = build(:phone_call_create_batch_operation)
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

  include_examples("batch_operation")
  include_examples("hash_store_accessor", :remote_request_params)
  include_examples("phone_call_operation_batch_operation")

  describe "#run!" do
    it "creates phone calls" do
      batch_operation = create(:phone_call_create_batch_operation)
      callout_participation = create_callout_participation(account: batch_operation.account)

      batch_operation.run!

      expect(batch_operation.phone_calls.size).to eq(1)
      created_phone_call = batch_operation.reload.phone_calls.first!
      expect(created_phone_call.callout_participation).to eq(callout_participation)
      expect(created_phone_call.remote_request_params).to eq(batch_operation.remote_request_params)
    end
  end
end
