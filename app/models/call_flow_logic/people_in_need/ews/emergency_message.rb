class CallFlowLogic::PeopleInNeed::EWS::EmergencyMessage < CallFlowLogic::Base
  def to_xml(_options = {})
    Twilio::TwiML::VoiceResponse.new do |response|
      response.play(
        url: Rails.application.routes.url_helpers.rails_blob_url(event.callout.voice)
      )
    end.to_s
  end
end
