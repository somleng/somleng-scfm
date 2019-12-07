require "rails_helper"

RSpec.describe CallFlowLogic::EWSRegistration do
  it "plays an introduction" do
    event = create_phone_call_event(phone_call_metadata: { status: nil })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      event: event,
      current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
    )

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(event.phone_call.metadata.fetch("status")).to eq("playing_introduction")
    expect(response).to eq(
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/introduction.wav",
      "Redirect" => "https://scfm.somleng.org/api/remote_phone_call_events"
    )
  end

  it "prompts for selecting the province" do
    event = create_phone_call_event(phone_call_metadata: { status: :playing_introduction })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
    expect(response.keys.size).to eq(1)
    expect(response.fetch("Gather")).to eq(
      "actionOnEmptyResult" => "true",
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/select_province.wav"
    )
  end

  it "gathers the province and prompts for gathering the district" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_province },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(event.phone_call.metadata.fetch("province_code")).to eq("15")
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
    expect(response.keys.size).to eq(1)
    expect(response.fetch("Gather")).to eq(
      "actionOnEmptyResult" => "true",
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/15.wav"
    )
  end

  it "gathers the district and prompts for gathering the commune" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_district, province_code: "15" },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(event.phone_call.metadata.fetch("district_code")).to eq("1501")
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_commune")
    expect(response.keys.size).to eq(1)
    expect(response.fetch("Gather")).to eq(
      "actionOnEmptyResult" => "true",
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/1501.wav"
    )
  end

  it "gathers the commune, updates the contact and plays a conclusion" do
    contact = create(
      :contact,
      metadata: {
        name: "John Doe",
        commune_ids: ["120101"]
      }
    )
    phone_call = create(
      :phone_call,
      :inbound,
      contact: contact,
      metadata: {
        status: :gathering_commune,
        province_code: "15",
        district_code: "1501"
      }
    )
    event = create_phone_call_event(phone_call: phone_call, event_details: { Digits: "5" })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      event: event,
      current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
    )

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(phone_call.metadata.fetch("commune_code")).to eq("150105")
    expect(phone_call.metadata.fetch("status")).to eq("playing_conclusion")
    expect(contact.metadata).to eq(
      "commune_ids" => %w[120101 150105],
      "name" => "John Doe"
    )
    expect(response).to eq(
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/registration_successful.wav",
      "Redirect" => "https://scfm.somleng.org/api/remote_phone_call_events"
    )
  end

  it "hangs up the call" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :playing_conclusion }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(response).to have_key("Hangup")
  end

  def parse_response(xml)
    Hash.from_xml(xml).fetch("Response")
  end

  def create_phone_call_event(options)
    phone_call = options.fetch(:phone_call) do
      create(:phone_call, metadata: options.fetch(:phone_call_metadata).compact)
    end
    default_event_details = attributes_for(:remote_phone_call_event).fetch(:details)
    details = options.fetch(:event_details, {}).reverse_merge(default_event_details)
    create(:remote_phone_call_event, phone_call: phone_call, details: details)
  end
end
