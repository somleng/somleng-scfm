require "rails_helper"

RSpec.describe CallFlowLogic::PeopleInNeed::EWS::EmergencyMessage do
  it_behaves_like("call_flow_logic")

  describe "#to_xml" do
    it "plays the emergency message" do
      account = create(:account)
      event = create_remote_phone_call_event(account: account)
      call_flow_logic = described_class.new(event: event)

      xml = call_flow_logic.to_xml

      response = Hash.from_xml(xml)["Response"]
      expect(response.keys.size).to eq(1)
      expect(response.fetch("Play")).to include(event.callout.voice_blob.filename.to_s)
    end
  end
end
