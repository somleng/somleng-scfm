require "rails_helper"

module CallFlowLogic
  RSpec.describe EWSLaosRegistration do
    it "plays an introduction in Lao" do
      event = create_phone_call_event(phone_call_metadata: { status: nil })
      call_flow_logic = EWSLaosRegistration.new(
        phone_call: event.phone_call,
        event:,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(event.phone_call.metadata.fetch("status")).to eq("playing_introduction")
      assert_play("introduction-lao.wav", response)
    end

    it "prompts for the province" do
      event = create_phone_call_event(
        phone_call_metadata: { status: :playing_introduction }
      )
      call_flow_logic = EWSLaosRegistration.new(
        phone_call: event.phone_call,
        event:
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather("select_province-lao.wav", response)
      expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
    end

    it "prompts for the province again if no input is received" do
      event = create_phone_call_event(
        phone_call_metadata: {
          status: :gathering_province
        }
      )
      call_flow_logic = EWSLaosRegistration.new(
        phone_call: event.phone_call,
        event:
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather("select_province-lao.wav", response)
      expect(event.phone_call.metadata["province_code"]).to eq(nil)
      expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
    end

    it "saves the province then prompts for the district" do
      event = create_phone_call_event(
        phone_call_metadata: {
          status: :gathering_province
        },
        event_details: { Digits: "1" }
      )
      call_flow_logic = EWSLaosRegistration.new(
        phone_call: event.phone_call,
        event:
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather("14-lao.wav", response)
      expect(event.phone_call.metadata.fetch("province_code")).to eq("14")
      expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
    end

    it "prompts for the district again if 0 is pressed" do
      event = create_phone_call_event(
        phone_call_metadata: {
          status: :gathering_district,
          province_code: "14"
        },
        event_details: { Digits: "0" }
      )
      call_flow_logic = EWSLaosRegistration.new(
        phone_call: event.phone_call,
        event:
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather("14-lao.wav", response)
      expect(event.phone_call.metadata["district_code"]).to eq(nil)
      expect(event.phone_call.metadata.fetch("status")).to eq("gathering_district")
    end

    it "starts over if * is pressed" do
      event = create_phone_call_event(
        phone_call_metadata: {
          status: :gathering_district,
          province_code: "14"
        },
        event_details: { Digits: "*" }
      )
      call_flow_logic = EWSLaosRegistration.new(
        phone_call: event.phone_call,
        event:
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(event.phone_call.metadata.fetch("status")).to eq("gathering_province")
      assert_gather("select_province-lao.wav", response)
    end

    it "saves the district, updates the contact and plays a conclusion" do
      contact = create(
        :contact,
        metadata: {
          name: "John Doe"
        }
      )
      phone_call = create(
        :phone_call,
        :inbound,
        contact:,
        metadata: {
          status: :gathering_district,
          province_code: "16"
        }
      )
      event = create_phone_call_event(phone_call:, event_details: { Digits: "4" })
      call_flow_logic = EWSLaosRegistration.new(
        phone_call:,
        event:,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(phone_call.metadata.fetch("district_code")).to eq("1604")
      expect(phone_call.metadata.fetch("status")).to eq("playing_conclusion")
      expect(contact.metadata).to eq(
        "name" => "John Doe",
        "latest_district_id" => "1604",
        "latest_address_en" => "Paksong District, Champasak Province",
        "latest_address_lo" => "ເມືອງປາກຊ່ອງ ແຂວງຈຳປາສັກ"
      )
      assert_play("registration_successful-lao.wav", response)
    end

    it "hangs up the call" do
      event = create_phone_call_event(
        phone_call_metadata: { status: :playing_conclusion }
      )
      call_flow_logic = EWSLaosRegistration.new(
        phone_call: event.phone_call,
        event:
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
      create(:remote_phone_call_event, phone_call:, details:)
    end

    def assert_gather(filename, response)
      expect(response.keys.size).to eq(1)
      expect(response.fetch("Gather")).to eq(
        "actionOnEmptyResult" => "true",
        "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_laos_registration/#{filename}"
      )
    end

    def assert_play(filename, response)
      expect(response).to eq(
        "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/ews_laos_registration/#{filename}",
        "Redirect" => "https://scfm.somleng.org/api/remote_phone_call_events"
      )
    end
  end
end
