module CallFlowLogic
  class EWSRegistration < Base
    def to_xml(_options = {})
      if gathering_data? && dtmf_tones.present?
        process_input
      end
      response = Twilio::TwiML::VoiceResponse.new
      # response.play(url: "https:/www.example.com/path-to-introduction.mp3")
      response.say(message: "Welcome to the early warning system registration 1294.")
      response.gather(action: current_url, action_on_empty_result: true) do |gather|
        update_phone_call!(status: :gathering_province)
        gather.say(message: "Please select your province by pressing the corresponding number on your keypad.")

        # gather.play(url: "https://www.example.com/path-to-list-of-provinces.mp3")
      end

      puts response.to_s
      response.to_s
    end
  end

  private

  def update_phone_call!(data)
    phone_call.update!(
      metadata: metadata.deep_merge(data)
    )
  end

  def gathering_data?
    call_status.starts_with?("gathering")
  end

  def dtmf_tones
    event.details["Digits"]
  end

  def pressed_digits
    dtmf_tones.to_i
  end

  def process_input
    return if pressed_digits.zero?

    result = {}
    if call_status == GATHERING_PROVINCE
      result[:province] = Selector::LOCATIONS.keys.fetch(dtfm_tones.to_i - 1)
    end

    update_phone_call!(result)
  end

  def call_status
    phone_call.metadata["status"].to_s
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

    attr_reader :phone_call, :digits

    def initialize(phone_call:, digits:)
      @phone_call = phone_call
      @digits = digits
    end
  end
end
