require 'rails_helper'

RSpec.describe JsonValidator do
  class JsonValidator::Validatable
    include ActiveModel::Validations
    attr_accessor  :json_attribute

    validates :json_attribute, :json => true

    def initialize(options = {})
      self.json_attribute = options[:json_attribute]
    end
  end

  subject { JsonValidator::Validatable.new(:json_attribute => json_value) }

  def setup_scenario
    super
    CallFlowLogic::Application
  end

  context "nil" do
    let(:json_value) { nil }
    it { is_expected.not_to be_valid }
  end

  context "invalid" do
    let(:json_value) { "foo" }
    it { is_expected.not_to be_valid }
  end

  context "valid" do
    let(:json_value) { {} }
    it { is_expected.to be_valid }
  end
end
