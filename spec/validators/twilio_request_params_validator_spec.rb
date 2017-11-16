require 'rails_helper'

RSpec.describe TwilioRequestParamsValidator do
  class TwilioRequestParamsValidator::Validatable
    include ActiveModel::Validations
    attr_accessor  :request_params

    validates :request_params, :twilio_request_params => true

    def initialize(options = {})
      self.request_params = options[:request_params]
    end
  end

  let(:request_params) { nil }
  subject { TwilioRequestParamsValidator::Validatable.new(:request_params => request_params) }

  context "without request params" do
    it { is_expected.to be_valid }
  end

  context "with invalid params" do
    let(:request_params) { { "foo" => "bar" } }
    it { is_expected.not_to be_valid }
  end

  context "with valid params" do
    let(:request_params) { Hash[[generate(:twilio_request_params).first]] }
    it { is_expected.to be_valid }
  end

  context "not passing a hash" do
    let(:request_params) { "foo" }
    it { is_expected.not_to be_valid }
  end
end
