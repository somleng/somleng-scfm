RSpec.shared_examples_for "call_flow_logic" do
  describe "#run!" do
    it "tries to complet the phone call" do
      phone_call = create(:phone_call, remote_status: "in-progress")
      event = create(:remote_phone_call_event, phone_call: phone_call)
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(phone_call.reload.status).not_to eq(PhoneCall::STATE_CREATED.to_s)
    end
  end
end
