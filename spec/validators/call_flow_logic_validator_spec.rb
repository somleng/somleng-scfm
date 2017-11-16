require 'rails_helper'

RSpec.describe CallFlowLogicValidator do
  class CallFlowLogicValidator::Validatable
    include ActiveModel::Validations
    attr_accessor  :call_flow_logic

    validates :call_flow_logic, :call_flow_logic => true

    def initialize(options = {})
      self.call_flow_logic = options[:call_flow_logic]
    end
  end

  subject { CallFlowLogicValidator::Validatable.new(:call_flow_logic => call_flow_logic) }

  def setup_scenario
    super
    CallFlowLogic::Application
  end

  context "blank" do
    let(:call_flow_logic) { nil }
    it { is_expected.to be_valid }
  end

  context "invalid" do
    let(:call_flow_logic) { Callout.to_s }
    it { is_expected.not_to be_valid }
  end

  context "valid" do
    let(:call_flow_logic) { CallFlowLogic::Application.to_s }
    it { is_expected.to be_valid }
  end
end
