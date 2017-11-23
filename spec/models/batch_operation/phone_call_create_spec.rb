require 'rails_helper'

RSpec.describe BatchOperation::PhoneCallCreate do
  let(:factory) { :phone_call_create_batch_operation }

  describe "associations" do
    it {
      is_expected.to have_many(:callout_participations)
      is_expected.to have_many(:contacts)
    }
  end

  describe "validations" do
    context "remote_request_params" do
      subject { build(factory, :remote_request_params => {}) }
      it { is_expected.not_to allow_value({"foo" => "bar"}).for(:remote_request_params) }
      it { is_expected.to validate_presence_of(:remote_request_params) }
    end

    context "phone_calls_preview" do
      let(:skip_validate_preview_presence) { nil }
      subject { build(factory, :skip_validate_preview_presence => skip_validate_preview_presence) }

      context "by default" do
        context "no callout participations in preview" do
          it {
            is_expected.not_to be_valid
            expect(subject.errors[:callout_participations_preview]).not_to be_empty
          }
        end

        context "callout participations in preview" do
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
  include_examples("hash_store_accessor", :remote_request_params)
  include_examples("phone_call_operation_batch_operation")

  describe "#run!" do
    let(:callout_participation) { create(:callout_participation) }
    subject { create(factory) }

    def setup_scenario
      super
      callout_participation
      subject.run!
    end

    let(:created_phone_call) { subject.reload.phone_calls.first }

    it {
      expect(created_phone_call).to be_present
      expect(subject.phone_calls.size).to eq(1)
      expect(created_phone_call.callout_participation).to eq(callout_participation)
      expect(created_phone_call.remote_request_params).to eq(subject.remote_request_params)
    }
  end
end
