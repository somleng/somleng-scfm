module CallFlowLogic
  class EWSRegistration < Base
    INITIAL_STATUS = :answered

    attr_reader :voice_response

    include AASM

    aasm(column: :status, whiny_transitions: false) do
      state INITIAL_STATUS, initial: true
      state :playing_introduction
      state :gathering_province
      state :gathering_district
      state :gathering_commune
      state :playing_conclusion
      state :finished

      before_all_events :read_status
      after_all_events :persist_status

      event :process_call do
        transitions from: :answered,
                    to: :playing_introduction,
                    after: :play_introduction

        transitions from: :playing_introduction,
                    to: :gathering_province,
                    after: :gather_province

        transitions from: :gathering_province,
                    to: :gathering_district,
                    if: :province_gathered?,
                    after: %i[persist_province gather_district]

        transitions from: :gathering_district,
                    to: :gathering_commune,
                    if: :district_gathered?,
                    after: %i[persist_district gather_commune]

        transitions from: :gathering_commune,
                    to: :playing_conclusion,
                    if: :commune_gathered?,
                    after: %i[persist_commune persist_location]

        transitions from: :playing_conclusion,
                    to: :finished
      end
    end

    def run!
      ApplicationRecord.transaction do
        super
        process_call
      end
    end

    def to_xml(_options = {})
      voice_response.to_s
    end

    private

    def read_status
      aasm.current_state = phone_call.metadata.fetch("status", INITIAL_STATUS).to_sym
    end

    def persist_status
      update_phone_call!(status: aasm.to_state)
    end

    def play_introduction
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        response.say(message: "Welcome to the early warning system registration 1294.")
      end
    end

    def gather_province
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true) do |gather|
          gather.say(message: "Please select your province by pressing the corresponding number on your keypad.")
        end
      end
    end

    def gather_district
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true) do |gather|
          gather.say(message: "Please select your district by pressing the corresponding number on your keypad.")
        end
      end
    end

    def gather_commune
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true) do |gather|
          gather.say(message: "Please select your commune by pressing the corresponding number on your keypad.")
        end
      end
    end

    def province_gathered?
      return false if pressed_digits.zero?

      selected_province.present?
    end

    def district_gathered?
      return false if pressed_digits.zero?

      selected_district.present?
    end

    def selected_province
      Selector::LOCATIONS.keys[pressed_digits - 1]
    end

    def selected_district
      Selector::LOCATIONS.fetch(phone_call.metadata.fetch("province").to_sym).keys[pressed_digits - 1]
    end

    def persist_province
      update_phone_call!(province: selected_province)
    end

    def persist_district
      update_phone_call!(district: selected_district)
    end

    def update_phone_call!(data)
      phone_call.update!(
        metadata: phone_call.metadata.deep_merge(data)
      )
    end

    def dtmf_tones
      event.details["Digits"]
    end

    def pressed_digits
      dtmf_tones.to_i
    end

    def phone_call
      event.phone_call
    end

    class Selector
      LOCATIONS = {
        pursat: {
          bakan: %i[
            boeng_bat_kandal
            boeng_khnar
            khnar_totueng
            me_tuek
            ou_ta_paong
            rumlech
            snam_preah
            svay_doun_kaev
            ta_lou
            trapeang_chorng
          ],
          kandieng: [],
          krakor: [],
          phnum_kravan: [],
          pursat_municipality: [],
          veal_veang: []
        },
        banteay_meanchey: {},
        kampong_thom: {},
        kampot: {},
        kampong_chhnang: {},
        siem_reap: {},
        battambang: {},
        kratie: {},
        steung_treng: {},
        preah_vihear: {},
        oddar_meanchey: {},
        kep: {},
        pailin: {},
        koh_kong: {},
        preah_sihanouk: {},
        kampong_cham: {},
        tboung_khmum: {},
        prey_veng: {},
        ratanakkiri: {},
        mondulkiri: {},
        svay_rieng: {},
        kampong_speu: {}
      }.freeze
    end
  end
end
