RSpec.shared_examples_for("has_call_flow_logic") do
  describe "validations" do
    it { is_expected.to validate_inclusion_of(:call_flow_logic).in_array(CallFlowLogic::Base.registered.map(&:to_s)) }
  end

  describe "#call_flow_logic=" do
    it "rejects blank call flow logic" do
      subject.call_flow_logic = ""
      expect(subject.call_flow_logic).to eq(nil)
    end
  end
end
