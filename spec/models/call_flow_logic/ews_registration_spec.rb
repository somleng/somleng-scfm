require "rails_helper"

RSpec.describe CallFlowLogic::EWSRegistration do
  it "plays an introduction" do
    event = create_phone_call_event(phone_call_metadata: { status: nil })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      event: event,
      current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(event.phone_call.metadata.fetch("status")).to eq("playing_introduction")
    assert_play("introduction.wav", response)
  end

  it "prompts for the province" do
    event = create_phone_call_event(phone_call_metadata: { status: :playing_introduction })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_province.wav", response)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
  end

  it "prompts for the province again if no input is received" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_province }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_province.wav", response)
    expect(event.phone_call.metadata["province_code"]).to eq(nil)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
  end

  it "saves the province then prompts for the district" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_province },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("15.wav", response)
    expect(event.phone_call.metadata.fetch("province_code")).to eq("15") # Pursat
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
  end

  it "prompts for the district again if 0 is pressed" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_district, province_code: "15" },
      event_details: { Digits: "0" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("15.wav", response)
    expect(event.phone_call.metadata["district_code"]).to eq(nil)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
  end

  it "starts over if * is pressed" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_district, province_code: "15" },
      event_details: { Digits: "*" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
    assert_gather("select_province.wav", response)
  end

  it "saves the district then prompts for the commune" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_district, province_code: "01" },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("0102.wav", response)
    expect(event.phone_call.metadata.fetch("district_code")).to eq("0102") # Mongkol Borei
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_commune")
  end

  it "prompts for the commune again if an invalid selection is received" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_commune, province_code: "15", district_code: "1501"
      },
      event_details: { Digits: "99" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("1501.wav", response)
    expect(event.phone_call.metadata.fetch("district_code")).to eq("1501")
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_commune")
  end

  it "saves the commune then updates the contact and plays a conclusion" do
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
        province_code: "01",
        district_code: "0105"
      }
    )
    event = create_phone_call_event(phone_call: phone_call, event_details: { Digits: "4" })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      event: event,
      current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(phone_call.metadata.fetch("commune_code")).to eq("010505") # Samraong
    expect(phone_call.metadata.fetch("status")).to eq("playing_conclusion")
    expect(contact.metadata).to eq(
      "commune_ids" => %w[120101 010505],
      "name" => "John Doe"
    )
    assert_play("registration_successful.wav", response)
  end

  it "hangs up the call" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :playing_conclusion }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
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

  def assert_gather(filename, response)
    expect(response.keys.size).to eq(1)
    expect(response.fetch("Gather")).to eq(
      "actionOnEmptyResult" => "true",
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/#{filename}"
    )
  end

  def assert_play(filename, response)
    expect(response).to eq(
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/#{filename}",
      "Redirect" => "https://scfm.somleng.org/api/remote_phone_call_events"
    )
  end
end
