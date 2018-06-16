require "rails_helper"

RSpec.describe CallFlowLogic::PlayMessage do
  it_behaves_like("call_flow_logic")

  describe "#to_xml" do
    it "plays the audio url" do
      audio_url = "https://www.example.com/audio_url"
      callout = create(:callout, audio_url: audio_url, account: account)
      event = create_event(account: account, callout: callout)
      call_flow_logic = described_class.new(event: event)

      xml = call_flow_logic.to_xml

      response = Hash.from_xml(xml)["Response"]
      expect(response.keys.size).to eq(1)
      play_response = response.fetch("Play")
      expect(play_response).to eq(audio_url)
    end

    it "plays an error message if there is no audio url" do
      event = create_event(account: account)
      call_flow_logic = described_class.new(event: event)

      xml = call_flow_logic.to_xml

      response = Hash.from_xml(xml)["Response"]
      expect(response.keys.size).to eq(1)
      say_response = response.fetch("Say")
      expect(say_response).to eq("No audio URL to play. Bye Bye")
    end
  end

  let(:account) { create(:account) }

  def create_event(account:, **options)
    callout = options.delete(:callout)
    return create_remote_phone_call_event(account: account) unless callout
    callout_participation = create_callout_participation(account: account, callout: callout)
    phone_call = create_phone_call(account: account, callout_participation: callout_participation)
    create_remote_phone_call_event(account: account, phone_call: phone_call)
  end
end
