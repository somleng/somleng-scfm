module CallFlowLogic
  class HelloWorld < CallFlowLogic::Base
    def to_xml(_options = {})
      Twilio::TwiML::VoiceResponse.new do |response|
        response.say(message: "Thanks for trying our documentation. Enjoy!")
        response.play(url: "https://demo.twilio.com/docs/classic.mp3")
      end.to_s
    end
  end
end
