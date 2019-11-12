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
      "Say" => "Welcome to the early warning system registration 1294.",
      "Redirect" => "https://scfm.somleng.org/api/remote_phone_call_events"
    )
  end

  it "prompts for gathering the province" do
    event = create_phone_call_event(phone_call_metadata: { status: :playing_introduction })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
    expect(response.keys.size).to eq(1)
    expect(response.fetch("Gather")).to eq(
      "actionOnEmptyResult" => "true",
      "Say" => "Please select your province by pressing the corresponding number on your keypad."
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
    expect(event.phone_call.metadata.fetch("province")).to eq("pursat")
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
    expect(response.keys.size).to eq(1)
    expect(response.fetch("Gather")).to eq(
      "actionOnEmptyResult" => "true",
      "Say" => "Please select your district by pressing the corresponding number on your keypad."
    )
  end

  it "gathers the district and prompts for gathering the commune" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_district, province: :pursat },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(event.phone_call.metadata.fetch("district")).to eq("bakan")
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_commune")
    expect(response.keys.size).to eq(1)
    expect(response.fetch("Gather")).to eq(
      "actionOnEmptyResult" => "true",
      "Say" => "Please select your commune by pressing the corresponding number on your keypad."
    )
  end

  it "gathers the commune and plays a conclusion" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_commune,
        province: :pursat,
        district: :bakan
      },
      event_details: { Digits: "5" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      event: event,
      current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
    )

    call_flow_logic.run!
    xml = call_flow_logic.to_xml

    response = parse_response(xml)
    expect(event.phone_call.metadata.fetch("commune")).to eq("ou_ta_paong")
    expect(event.phone_call.metadata.fetch("status")).to eq("playing_conclusion")
    expect(response).to eq(
      "Say" => "Thank you. You have successfully registered for the EWS System.",
      "Redirect" => "https://scfm.somleng.org/api/remote_phone_call_events"
    )
  end

  it "Hangs up the call" do
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

  def create_phone_call_event(phone_call_metadata:, event_details: {})
    phone_call = create(:phone_call, { metadata: phone_call_metadata.compact })
    details = event_details.reverse_merge(attributes_for(:remote_phone_call_event).fetch(:details))
    create(:remote_phone_call_event, phone_call: phone_call, details: details)
  end
end
