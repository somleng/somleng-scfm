require 'rails_helper'

RSpec.describe CallFlowLogic::Application do
  let(:event) { create(:remote_phone_call_event) }
  subject { described_class.new(:event => event) }

  it_behaves_like("call_flow_logic")

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
