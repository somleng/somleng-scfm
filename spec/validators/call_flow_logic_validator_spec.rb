require "rails_helper"

RSpec.describe CallFlowLogicValidator do
  it "validates call flow logic" do
    validatable_klass = Struct.new(:call_flow_logic) do
      include ActiveModel::Validations

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :call_flow_logic, call_flow_logic: true
    end

    expect(validatable_klass.new(nil).valid?).to eq(true)
    expect(validatable_klass.new("Callout").valid?).to eq(false)
    expect(validatable_klass.new("CallFlowLogic::HelloWorld").valid?).to eq(true)
  end
end
