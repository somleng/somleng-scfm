class CallFlowLogic::PeopleInNeed::EWS::EmergencyMessage < CallFlowLogic::Base
  def to_xml(_options = {})
    Twilio::TwiML::VoiceResponse.new do |response|
      # Don't use rails_blob_url here
      # It will redirect and mod_httapi can't follow redirects
      response.play(
        url: event.callout.voice.service_url
      )
    end.to_s
  end
end
