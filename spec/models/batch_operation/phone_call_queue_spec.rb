require 'rails_helper'

RSpec.describe BatchOperation::PhoneCallQueue do
  let(:factory) { :phone_call_queue_batch_operation }

  describe "associations" do
    it {
      is_expected.to have_many(:phone_calls).dependent(:restrict_with_error)
    }
  end

  describe "validations" do
    context "phone_calls_preview" do
      let(:skip_validate_preview_presence) { nil }
      subject { build(factory, :skip_validate_preview_presence => skip_validate_preview_presence) }

      context "by default" do
        context "no phone calls in preview" do
          it {
            is_expected.not_to be_valid
            expect(subject.errors[:phone_calls_preview]).not_to be_empty
          }
        end

        context "phone calls in preview" do
          def setup_scenario
            create(:phone_call)
          end

          it { is_expected.to be_valid }
        end
      end

      context "skip_validate_preview_presence=true" do
        let(:skip_validate_preview_presence) { true }
        it { is_expected.to be_valid }
      end
    end
  end

  include_examples("batch_operation")
  include_examples("phone_call_operation_batch_operation")
  include_examples("hash_store_accessor", :phone_call_filter_params)

  describe "#run!" do
    let(:phone_call) { create(:phone_call) }
    subject { create(factory) }

    def setup_scenario
      super
      phone_call
      subject.run!
    end

    let(:queued_phone_call) { subject.reload.phone_calls.first }

    it {
      expect(queued_phone_call).to be_present
      expect(subject.phone_calls.size).to eq(1)
      expect(queued_phone_call).to be_queued
    }
  end
end
