require "rails_helper"

RSpec.describe CallFlowLogic::HelloWorld do
  it_behaves_like("call_flow_logic")

  describe "#to_xml" do
    it "returns TwiML for hello world" do
      event = create(:remote_phone_call_event)
      call_flow_logic = described_class.new(event: event)

      xml = call_flow_logic.to_xml

      response = Hash.from_xml(xml).fetch("Response")
      expect(response.keys.size).to eq(2)
      expect(response.fetch("Say")).to eq("Thanks for trying our documentation. Enjoy!")
      expect(response.fetch("Play")).to eq("http://demo.twilio.com/docs/classic.mp3")
    end
  end
end
