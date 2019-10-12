module CallFlowLogic
  class EWSRegistration < Base
    def to_xml(_options = {})
      response = Twilio::TwiML::VoiceResponse.new
      # response.play(url: "https:/www.example.com/path-to-introduction.mp3")
      response.say("Welcome to the early warning system registration 1294.")
      response.gather(action: current_url, action_on_empty_result: true) do |gather|
        gather.say("Please select your province by pressing the corresponding number on your keypad.")
        # gather.play(url: "https://www.example.com/path-to-list-of-provinces.mp3")
      end

      puts response.to_xml
    end
  end
end
