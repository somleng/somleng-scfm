RSpec.shared_examples_for "call_flow_logic" do
  describe "#run!" do
    let(:phone_call) { create(:phone_call, :remote_status => "in-progress") }
    let(:event) { create(:remote_phone_call_event, :phone_call => phone_call) }
    subject { described_class.new(:event => event) }

    def setup_scenario
      subject.run!
    end

    it { expect(phone_call.reload.status).not_to eq(PhoneCall::STATE_CREATED.to_s) }
  end
end
