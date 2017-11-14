require 'rails_helper'

RSpec.describe BatchOperation::PhoneCallCreate do
  let(:factory) { :phone_call_create_batch_operation }
  include_examples("batch_operation")

  describe "associations" do
    it {
      is_expected.to have_many(:phone_calls).dependent(:restrict_with_error)
      is_expected.to have_many(:callout_participations)
      is_expected.to have_many(:contacts)
    }
  end

  describe "validations" do
    context "remote_request_params" do
      subject { build(factory, :remote_request_params => {"foo" => "bar"}) }
      it { is_expected.not_to be_valid }
      it { is_expected.to validate_presence_of(:remote_request_params) }
    end
  end

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
