require "rails_helper"

RSpec.describe BatchOperation::PhoneCallQueue do
  let(:factory) { :phone_call_queue_batch_operation }

  include_examples("phone_call_operation_batch_operation")
  include_examples("phone_call_event_operation_batch_operation")

  describe "#parameters" do
    it "is valid when there is a phone call to preview " do
      account = create(:account)
      _phone_call = create_phone_call(account: account)
      batch_operation = build(factory, account: account, parameters: {})

      expect(batch_operation).to be_valid
    end

    it "can set the parameters from the account settings" do
      account = build_stubbed(
        :account,
        settings: {
          "batch_operation_phone_call_queue_parameters" => {
            "phone_call_filter_params" => {
              "status" => "created"
            }
          }
        }
      )
      batch_operation = described_class.new(account: account)

      batch_operation.valid?

      expect(batch_operation.parameters).to eq(
        account.settings.fetch("batch_operation_phone_call_queue_parameters")
      )
    end
  end

  describe "#phone_calls_preview" do
    it "selects phone calls in a random order" do
      batch_operation = create(:phone_call_queue_batch_operation)
      phone_calls = create_phone_calls(account: batch_operation.account)

      results = []
      100.times do
        results = batch_operation.phone_calls_preview
        break results unless results == phone_calls
      end

      expect(results).to match_array(phone_calls)
      expect(results).not_to eq(phone_calls)
    end
  end

  describe "#run!" do
    it "queues the phone calls in a random order" do
      batch_operation = nil
      phone_calls = []
      applied_phone_calls = []

      100.times do
        batch_operation = create(:phone_call_queue_batch_operation)
        phone_calls = create_phone_calls(:created, account: batch_operation.account)

        batch_operation.run!

        applied_phone_calls = batch_operation.phone_calls.order(:updated_at)

        break unless applied_phone_calls == phone_calls
      end

      expect(applied_phone_calls).to match_array(phone_calls)
      expect(applied_phone_calls).not_to eq(phone_calls)
      expect(phone_calls.first.reload).to be_queued
    end
  end

  def create_phone_calls(*args, **options)
    results = []
    2.times do
      results << create_phone_call(*args, **options)
    end
    results
  end
end
