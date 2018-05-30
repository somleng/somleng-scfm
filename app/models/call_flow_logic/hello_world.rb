class CallFlowLogic::HelloWorld < CallFlowLogic::Base
  def to_xml(_options = {})
    Twilio::TwiML::VoiceResponse.new do |response|
      response.say("Thanks for trying our documentation. Enjoy!")
      response.play(url: "http://demo.twilio.com/docs/classic.mp3")
    end.to_s
  end
end
