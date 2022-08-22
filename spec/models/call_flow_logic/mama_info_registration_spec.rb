require "rails_helper"

module CallFlowLogic
  RSpec.describe MamaInfoRegistration do
    it "plays an introduction" do
      event = create_phone_call_event
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: event.phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(event.phone_call.metadata.fetch("status")).to eq("playing_introduction")
      assert_play(audio_url(:introduction), response)
    end

    # Already registered flow

    it "handles users who are already registered" do
      contact = create(:contact, metadata: { date_of_birth: "2023-01-01" })
      phone_call = create(:phone_call, contact: contact, metadata: { status: :playing_introduction })
      event = create_phone_call_event(phone_call: phone_call)
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(phone_call.metadata.fetch("status")).to eq("playing_already_registered")
      assert_play(audio_url(:already_registered), response)
    end

    it "plays the registered date of birth (future)" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        contact = create(:contact, metadata: { date_of_birth: "2023-01-01" })
        phone_call = create(:phone_call, contact: contact, metadata: { status: :playing_already_registered })
        event = create_phone_call_event(phone_call: phone_call)
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          phone_call: phone_call,
          event: event,
          current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        expect(phone_call.metadata.fetch("status")).to eq("playing_registered_date_of_birth")
        expect(response.fetch("Play")).to eq(
          [
            audio_url(:confirm_pregnancy_status),
            audio_url(:january),
            audio_url("2023")
          ]
        )
      end
    end

    it "plays the registered date of birth (past)" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        contact = create(:contact, metadata: { date_of_birth: "2022-01-01" })
        phone_call = create(:phone_call, contact: contact, metadata: { status: :playing_already_registered })
        event = create_phone_call_event(phone_call: phone_call)
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          phone_call: phone_call,
          event: event,
          current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        expect(phone_call.metadata.fetch("status")).to eq("playing_registered_date_of_birth")
        expect(response.fetch("Play")).to eq(
          [
            audio_url(:confirm_age),
            audio_url(:january),
            audio_url("2022")
          ]
        )
      end
    end

    it "gathers whether to update details or deregister" do
      contact = create(:contact, metadata: { date_of_birth: "2022-01-01" })
      phone_call = create(:phone_call, contact: contact, metadata: { status: :playing_registered_date_of_birth })
      event = create_phone_call_event(phone_call: phone_call)
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_update_details_or_deregister")
      assert_gather(audio_url(:gather_update_details_or_deregister), response)
    end

    it "updates the details" do
      contact = create(:contact, metadata: { date_of_birth: "2022-01-01" })
      phone_call = create(:phone_call, contact: contact, metadata: { status: :gathering_update_details_or_deregister })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_mothers_status")
      assert_gather(audio_url(:gather_mothers_status), response)
    end

    it "deregisters the user" do
      contact = create(:contact, metadata: { date_of_birth: "2022-01-01" })
      phone_call = create(:phone_call, contact: contact, metadata: { status: :gathering_update_details_or_deregister })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(phone_call.metadata.fetch("status")).to eq("playing_deregistered")
      expect(contact.metadata.fetch("deregistered_at")).to be_present
      expect(contact.metadata.key?("date_of_birth")).to eq(false)
      assert_play(audio_url(:deregistration_successful), response)
    end

    it "handles invalid inputs" do
      contact = create(:contact, metadata: { date_of_birth: "2022-01-01" })
      phone_call = create(:phone_call, contact: contact, metadata: { status: :gathering_update_details_or_deregister })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "3" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_update_details_or_deregister")
      assert_regather_invalid_response(audio_url(:gather_update_details_or_deregister), response)
    end

    it "gathers the mother's status" do
      phone_call = create(:phone_call, metadata: { status: :playing_introduction })
      event = create_phone_call_event(phone_call: phone_call)
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_mothers_status")
      assert_gather(audio_url(:gather_mothers_status), response)
    end

    it "handles invalid inputs for mother's status" do
      phone_call = create(:phone_call, metadata: { status: :gathering_mothers_status })
      event = create_phone_call_event(phone_call: phone_call)

      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:gather_mothers_status), response)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_mothers_status")
    end

    it "allows mothers to listen again" do
      phone_call = create(:phone_call, metadata: { status: :gathering_mothers_status })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "3" }
      )

      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_mothers_status), response)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_mothers_status")
    end

    # Pregnant flow

    it "gathers the pregnancy status" do
      phone_call = create(:phone_call, metadata: { status: :gathering_mothers_status })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_pregnancy_status), response)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_pregnancy_status")
    end

    it "handles valid pregnancy status inputs" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        phone_call = create(:phone_call, metadata: { status: :gathering_pregnancy_status })
        event = create_phone_call_event(
          phone_call: phone_call,
          event_details: { Digits: "2" }
        )
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          phone_call: phone_call,
          event: event
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        assert_gather(
          [
            audio_url(:confirm_pregnancy_status),
            audio_url(:january),
            audio_url("2023"),
            audio_url(:confirm_input)
          ],
          response
        )
        expect(phone_call.metadata.fetch("unconfirmed_date_of_birth")).to eq("2023-01-01")
        expect(phone_call.metadata.fetch("status")).to eq("confirming_pregnancy_status")
      end
    end

    it "handles invalid pregnancy status inputs" do
      phone_call = create(:phone_call, metadata: { status: :gathering_pregnancy_status })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "10" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:gather_pregnancy_status), response)
      expect(event.phone_call.metadata.fetch("status")).to eq("gathering_pregnancy_status")
    end

    it "handles valid pregnancy status confirmation inputs" do
      phone_call = create(
        :phone_call,
        metadata: {
          status: :confirming_pregnancy_status,
          unconfirmed_date_of_birth: "2023-01-01"
        }
      )
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_play(audio_url(:registration_successful), response)
      expect(phone_call.metadata.fetch("date_of_birth")).to eq("2023-01-01")
      expect(phone_call.metadata.fetch("status")).to eq("playing_registration_successful")
      expect(phone_call.contact.metadata.fetch("date_of_birth")).to eq("2023-01-01")
    end

    it "handles invalid pregnancy status confirmation inputs" do
      phone_call = create(
        :phone_call,
        metadata: {
          status: :confirming_pregnancy_status
        }
      )
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "3" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:confirm_pregnancy_status), response)
      expect(phone_call.metadata.fetch("status")).to eq("confirming_pregnancy_status")
    end

    it "handles pregnancy status re-inputs" do
      phone_call = create(
        :phone_call,
        metadata: {
          status: :confirming_pregnancy_status
        }
      )
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_pregnancy_status), response)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_pregnancy_status")
    end

    # Child already born flow

    it "gathers the child's age" do
      phone_call = create(:phone_call, metadata: { status: :gathering_mothers_status })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_age), response)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_age")
    end

    it "handles valid age inputs" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        phone_call = create(:phone_call, metadata: { status: :gathering_age })
        event = create_phone_call_event(
          phone_call: phone_call,
          event_details: { Digits: "6" }
        )
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          phone_call: phone_call,
          event: event
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        assert_gather(
          [
            audio_url(:confirm_age),
            audio_url(:december),
            audio_url("2021"),
            audio_url(:confirm_input)
          ],
          response
        )
        expect(phone_call.metadata.fetch("status")).to eq("confirming_age")
        expect(phone_call.metadata.fetch("unconfirmed_date_of_birth")).to eq("2021-12-01")
      end
    end

    it "handles invalid age inputs" do
      phone_call = create(:phone_call, metadata: { status: :gathering_age })
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "100" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:gather_age), response)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_age")
    end

    it "handles valid age confirmation inputs" do
      contact = create(:contact, metadata: { deregistered_at: Time.current })

      phone_call = create(
        :phone_call,
        :inbound,
        contact: contact,
        metadata: {
          status: :confirming_age,
          unconfirmed_date_of_birth: "2023-01-01"
        }
      )
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event,
        current_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_play(audio_url(:registration_successful), response)
      expect(phone_call.metadata.fetch("date_of_birth")).to eq("2023-01-01")
      expect(phone_call.metadata.fetch("status")).to eq("playing_registration_successful")
      expect(phone_call.contact.metadata.fetch("date_of_birth")).to eq("2023-01-01")
      expect(phone_call.contact.metadata.key?("deregistered_at")).to eq(false)
    end

    it "handles invalid age confirmation inputs" do
      phone_call = create(
        :phone_call,
        metadata: {
          status: :confirming_age
        }
      )
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "3" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:confirm_age), response)
      expect(phone_call.metadata.fetch("status")).to eq("confirming_age")
    end

    it "handles age re-inputs" do
      phone_call = create(
        :phone_call,
        metadata: {
          status: :confirming_age
        }
      )
      event = create_phone_call_event(
        phone_call: phone_call,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_age), response)
      expect(phone_call.metadata.fetch("status")).to eq("gathering_age")
    end

    it "finishes the call" do
      phone_call = create(
        :phone_call,
        metadata: {
          status: :playing_registration_successful
        }
      )
      event = create_phone_call_event(
        phone_call: phone_call
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        phone_call: phone_call,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(response).to have_key("Hangup")
      expect(phone_call.metadata.fetch("status")).to eq("finished")
    end

    def create_phone_call_event(options = {})
      phone_call = options.fetch(:phone_call) { create(:phone_call) }
      default_event_details = attributes_for(:remote_phone_call_event).fetch(:details)
      details = options.fetch(:event_details, {}).reverse_merge(default_event_details)
      create(:remote_phone_call_event, phone_call: phone_call, details: details)
    end

    def parse_response(xml)
      Hash.from_xml(xml).fetch("Response")
    end

    def assert_play(filename, response)
      expect(response).to eq(
        "Play" => filename,
        "Redirect" => "https://scfm.somleng.org/api/remote_phone_call_events"
      )
    end

    def assert_gather(filename, response)
      expect(response.keys.size).to eq(1)
      expect(response.fetch("Gather")).to eq(
        "actionOnEmptyResult" => "true",
        "Play" => filename
      )
    end

    def assert_regather_invalid_response(filename, response)
      expect(response).to eq(
        "Play" => audio_url(:invalid_response),
        "Gather" => {
          "actionOnEmptyResult" => "true",
          "Play" => filename
        }
      )
    end

    def audio_url(filename)
      "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/mama_info_registration/#{filename}-loz.mp3"
    end
  end
end
