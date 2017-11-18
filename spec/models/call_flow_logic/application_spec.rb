require 'rails_helper'

RSpec.describe CallFlowLogic::Application do
  let(:remote_phone_call_event) { create(:remote_phone_call_event) }
  subject { described_class.new(remote_phone_call_event) }

  describe "#to_xml" do
    let(:xml) { subject.to_xml }
    let(:parsed_xml) { Hash.from_xml(xml) }

    def assert_xml!
      response = parsed_xml["Response"]
      expect(response).to be_present
      expect(response["Say"]).to eq("Thanks for trying our documentation. Enjoy!")
      expect(response["Play"]).to eq("http://demo.twilio.com/docs/classic.mp3")
    end

    it { assert_xml! }
  end
end
