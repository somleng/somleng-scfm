require 'rails_helper'

RSpec.describe BatchOperation::PhoneCallCreate do
  let(:factory) { :phone_call_create_batch_operation }
  include_examples("batch_operation")

  describe "validations" do
    context "remote_request_params" do
      subject { build(factory, :remote_request_params => {"foo" => "bar"}) }
      it { is_expected.not_to be_valid }
      it { is_expected.to validate_presence_of(:remote_request_params) }
    end
  end

  include_examples("hash_attr_accessor", :remote_request_params, :callout_filter_params)

  describe "#run!" do

  end
end
