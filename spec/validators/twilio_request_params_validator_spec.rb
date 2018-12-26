require "rails_helper"

RSpec.describe TwilioRequestParamsValidator do
  class TwilioRequestParamsModel
    include ActiveModel::Model
    attr_accessor :request_params

    validates :request_params, twilio_request_params: true
  end

  it { expect(build_validatable("foo" => "bar")).to be_invalid }
  it { expect(build_validatable("foo")).to be_invalid }
  it { expect(build_validatable(nil)).to be_valid }
  it { expect(build_validatable(Hash[[generate(:twilio_request_params).first]])).to be_valid }

  def build_validatable(request_params)
    TwilioRequestParamsModel.new(request_params: request_params)
  end
end
