require "rails_helper"

module BatchOperation
  RSpec.describe PhoneCallCreate do
    let(:factory) { :phone_call_create_batch_operation }

    it "validates the remote request params" do
      batch_operation = build(:phone_call_create_batch_operation)
      expect(batch_operation).not_to allow_value("foo" => "bar").for(:remote_request_params)
      expect(build(:phone_call_create_batch_operation)).to validate_presence_of(:remote_request_params)
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

    describe "#parameters" do
      it "can set the parameters from the account settings" do
        account = create(
          :account,
          settings: {
            "batch_operation_phone_call_create_parameters" => {
              "callout_filter_params" => {
                "status" => "running"
              }
            }
          }
        )
        batch_operation = build(:phone_call_create_batch_operation, account: account)

        batch_operation.save!

        expect(batch_operation.parameters).to include(
          "callout_filter_params" => {
            "status" => "running"
          }
        )
      end
    end

    include_examples("hash_store_accessor", :remote_request_params)
    include_examples("phone_call_operation_batch_operation")

    describe "#run!" do
      it "creates phone calls" do
        account = create(:account)
        callout_participation = create_callout_participation(account: account)
        batch_operation = create(:phone_call_create_batch_operation, account: account)

        2.times { batch_operation.run! }

        expect(batch_operation.phone_calls.size).to eq(1)
        expect(batch_operation.phone_calls.first).to have_attributes(
          callout_participation: callout_participation,
          contact: callout_participation.contact,
          account: account
        )
      end
    end

    describe "#callout_participations_preview" do
    end
  end
end
