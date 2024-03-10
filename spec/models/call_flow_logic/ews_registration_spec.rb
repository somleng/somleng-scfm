require "rails_helper"

RSpec.describe CallFlowLogic::EWSRegistration do
  it "plays an introduction in Khmer" do
    event = create_phone_call_event(phone_call_metadata: { status: nil })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(event.phone_call.metadata.fetch("status")).to eq("playing_introduction")
    assert_play("introduction-khm.wav", response)
  end

  it "prompts the main menu" do
    contact = create(:contact, msisdn: "+855715100860")
    phone_call = create(
      :phone_call,
      :inbound,
      contact:,
      msisdn: contact.msisdn,
      metadata: { status: :playing_introduction }
    )
    event = create_phone_call_event(phone_call:)
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("main_menu-khm.mp3", response)
    expect(event.phone_call.metadata.fetch("status")).to eq("main_menu")
  end

  it "gathers feedback" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :main_menu },
      event_details: { Digits: "2" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(response).to include(
      "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_registration/record_feedback_instructions-khm.mp3",
      "Record" => {
        "recordingStatusCallback" => "https://scfm.somleng.org/twilio_webhooks/recording_status_callbacks"
      }
    )
    expect(event.phone_call.metadata.fetch("status")).to eq("recording_feedback")
  end

  it "thanks the caller for providing feedback" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :recording_feedback }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_play("feedback_successful-khm.mp3", response)
    expect(event.phone_call.metadata.fetch("status")).to eq("playing_feedback_successful")
  end

  it "completes the feedback flow" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :playing_feedback_successful }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(response).to have_key("Hangup")
  end

  it "starts the registration process" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :main_menu },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_language.wav", response)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_language")
  end

  it "starts the registration process if no input is received" do
    event = create_phone_call_event(phone_call_metadata: { status: :main_menu })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_language.wav", response)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_language")
  end

  it "handles invalid main menu responses" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :main_menu },
      event_details: { Digits: "3" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("main_menu-khm.mp3", response)
    expect(event.phone_call.metadata.fetch("status")).to eq("main_menu")
  end

  it "prompts for the language again if no input is received" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_language }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(event: event, phone_call: event.phone_call)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_language.wav", response)
    expect(event.phone_call.metadata["language_code"]).to eq(nil)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_language")
  end

  it "saves the language then prompts for the province in the selected language" do
    event = create_phone_call_event(
      phone_call_metadata: { status: :gathering_language },
      event_details: { Digits: "2" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_province-cmo.wav", response)
    expect(event.phone_call.metadata.fetch("language_code")).to eq("cmo") # Central Mnong
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
  end

  it "prompts for the province again if no input is received" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_province,
        language_code: "khm"
      }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_province-khm.wav", response)
    expect(event.phone_call.metadata["province_code"]).to eq(nil)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
  end

  it "prompts for the province again if the province is not available in the selected language" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_province,
        language_code: "krr" # Krung
      },
      event_details: { Digits: "1" } # Pursat
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("select_province-krr.wav", response)
    expect(event.phone_call.metadata["province_code"]).to eq(nil)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
  end

  it "saves the province then prompts for the district in the selected language" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_province,
        language_code: "khm"
      },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("15-khm.wav", response)
    expect(event.phone_call.metadata.fetch("province_code")).to eq("15") # Pursat
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
  end

  it "prompts for the district again if 0 is pressed" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_district,
        province_code: "15",
        language_code: "khm"
      },
      event_details: { Digits: "0" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("15-khm.wav", response)
    expect(event.phone_call.metadata["district_code"]).to eq(nil)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
  end

  it "starts over if * is pressed" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_district,
        province_code: "15",
        language_code: "khm"
      },
      event_details: { Digits: "*" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_language")
    assert_gather("select_language.wav", response)
  end

  it "saves the district then prompts for the commune in the selected language" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_district,
        province_code: "01",
        language_code: "khm"
      },
      event_details: { Digits: "1" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("0102-khm.wav", response)
    expect(event.phone_call.metadata.fetch("district_code")).to eq("0102") # Mongkol Borei
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_commune")
  end

  it "prompts for the commune again if an invalid selection is received" do
    event = create_phone_call_event(
      phone_call_metadata: {
        status: :gathering_commune,
        province_code: "15",
        district_code: "1501",
        language_code: "khm"
      },
      event_details: { Digits: "99" }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(phone_call: event.phone_call, event: event)

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    assert_gather("1501-khm.wav", response)
    expect(event.phone_call.metadata.fetch("district_code")).to eq("1501")
    expect(event.phone_call.metadata.fetch("status")).to eq("gathering_commune")
  end

  it "saves the commune, updates the contact and plays a conclusion" do
    contact = create(
      :contact,
      metadata: {
        name: "John Doe",
        language_code: "khm",
        commune_ids: ["120101"]
      }
    )
    phone_call = create(
      :phone_call,
      :inbound,
      contact: contact,
      metadata: {
        status: :gathering_commune,
        language_code: "krr",
        province_code: "01",
        district_code: "0105"
      }
    )
    event = create_phone_call_event(phone_call: phone_call, event_details: { Digits: "4" })
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: phone_call,
      event: event,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

    call_flow_logic.run!

    response = parse_response(call_flow_logic.to_xml)
    expect(phone_call.metadata.fetch("commune_code")).to eq("010505") # Samraong
    expect(phone_call.metadata.fetch("status")).to eq("playing_conclusion")
    expect(contact.metadata).to eq(
      "commune_ids" => %w[120101 010505],
      "name" => "John Doe",
      "language_code" => "krr",
      "latest_commune_id" => "010505",
      "latest_address_km" => "ឃុំសំរោង ស្រុកអូរជ្រៅ ខេត្តបន្ទាយមានជ័យ",
      "latest_address_en" => "Samraong Commune, Ou Chrov District, Banteay Meanchey Province"
    )
    assert_play("registration_successful-krr.wav", response)
  end

  it "hangs up the call" do
    event = create_phone_call_event(
      phone_call_metadata: {
        language_code: "khm",
        status: :playing_conclusion
      }
    )
    call_flow_logic = CallFlowLogic::EWSRegistration.new(
      phone_call: event.phone_call,
      event:,
      current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )

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
      "Redirect" => "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
    )
  end
end
