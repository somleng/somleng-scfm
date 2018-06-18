RSpec.shared_examples_for("has_call_flow_logic") do
  describe "validations" do
    it { is_expected.to validate_inclusion_of(:call_flow_logic).in_array(CallFlowLogic::Base.registered.map(&:to_s)) }

    it "validates presence of call flow logic" do
      subject = create(factory)
      subject.call_flow_logic = nil

      expect(subject).not_to be_valid
      expect(subject.errors[:call_flow_logic]).to be_present
    end
  end

  describe "#call_flow_logic=" do
    it "rejects blank call flow logic" do
      subject.call_flow_logic = ""
      expect(subject.call_flow_logic).to eq(nil)
    end
  end
end
