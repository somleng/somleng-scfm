module CallFlowLogic
  class EWSRegistration < Base
    # http://db.ncdd.gov.kh/gazetteer/view/index.castle
    PROVINCE_MENU = [
      "15", # Pursat
      "01", # Banteay Meanchey
      "06", # Kampong Thom
      "07", # Kampot
      "04", # Kampong Chhnang
      "17", # Siem Reap
      "02", # Battambang
      "10", # Kratie,
      "19", # Steung Treng
      "13", # Preah Vihear
      "22", # Oddar Meanchey
      "23", # Kep
      "24", # Pailin
      "09", # Koh Kong
      "18", # Preah Sihanouk
      "03", # Kampong Cham
      "25", # Tboung Khmum
      "14", # Prey Veng
      "16", # Ratanakkiri
      "11", # Mondulkiri
      "20", # Svay Rieng
      "05", # Kampong Speu
      "21", # Takao
      "08", # Kandal
      "12"  # Phnom Penh
    ].freeze

    # https://en.wikipedia.org/wiki/ISO_639-3
    LANGUAGE_MENU = [
      "khm", # Khmer (https://iso639-3.sil.org/code/khm, https://en.wikipedia.org/wiki/Khmer_language)
      "cmo", # Central Mnong (https://iso639-3.sil.org/code/cmo, https://en.wikipedia.org/wiki/Mnong_language)
      "jra", # Jarai (https://iso639-3.sil.org/code/jra, https://en.wikipedia.org/wiki/Jarai_language)
      "tpu", # Tampuan (https://iso639-3.sil.org/code/tpu, https://en.wikipedia.org/wiki/Tampuan_language)
      "krr"  # Krung (https://iso639-3.sil.org/code/krr, https://en.wikipedia.org/wiki/Brao_language)
    ].freeze

    INITIAL_STATUS = :answered

    attr_reader :voice_response

    include AASM

    aasm(column: :status, whiny_transitions: false) do
      state INITIAL_STATUS, initial: true
      state :playing_introduction
      state :gathering_language
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
                    to: :gathering_language,
                    after: :gather_language

        transitions from: :gathering_language,
                    to: :gathering_province,
                    if: :language_gathered?,
                    after: %i[persist_language gather_province]

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
                    after: %i[persist_commune update_contact play_conclusion]

        transitions from: %i[gathering_district gathering_commune],
                    to: :gathering_province,
                    if: :start_over?,
                    after: %i[gather_province]

        transitions from: :playing_conclusion,
                    to: :finished,
                    after: :hangup
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
        play(:introduction, response)
        response.redirect(current_url)
      end
    end

    def gather_language
      @voice_response = gather do |response|
        play(:select_language, response)
      end
    end

    def gather_province
      @voice_response = gather do |response|
        play(:select_province, response)
      end
    end

    def gather_district
      @voice_response = gather do |response|
        play(phone_call_metadata(:province_code), response)
      end
    end

    def gather_commune
      @voice_response = gather do |response|
        play(phone_call_metadata(:district_code), response)
      end
    end

    def play_conclusion
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(:registration_successful, response)
        response.redirect(current_url)
      end
    end

    def gather(&_block)
      Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true) do |gather|
          yield(gather)
        end
      end
    end

    def play(filename, response)
      response.play(url: AudioURL.new(key: "ews_registration/#{filename}.wav").url)
    end

    def hangup
      @voice_response = Twilio::TwiML::VoiceResponse.new(&:hangup)
    end

    def start_over?
      dtmf_tones.to_s.first == "*"
    end

    def language_gathered?
      return true if selected_language.present?

      gather_language
      false
    end

    def province_gathered?
      return true if selected_province.present?

      gather_province
      false
    end

    def district_gathered?
      return true if selected_district.present?

      gather_district
      false
    end

    def commune_gathered?
      return true if selected_commune.present?

      gather_commune
      false
    end

    def selected_language
      return if pressed_digits.zero?

      LANGUAGE_MENU[pressed_digits - 1]
    end

    def selected_province
      return if pressed_digits.zero?

      PROVINCE_MENU[pressed_digits - 1]
    end

    def selected_district
      return if pressed_digits.zero?

      province_code = phone_call_metadata(:province_code)
      districts = Pumi::District.where(province_id: province_code).sort_by(&:id)
      districts[pressed_digits - 1]&.id
    end

    def selected_commune
      return if pressed_digits.zero?

      district_code = phone_call_metadata(:district_code)
      communes = Pumi::Commune.where(district_id: district_code).sort_by(&:id)
      communes[pressed_digits - 1]&.id
    end

    def persist_language
      update_phone_call!(language: selected_language)
    end

    def persist_province
      update_phone_call!(province_code: selected_province)
    end

    def persist_district
      update_phone_call!(district_code: selected_district)
    end

    def persist_commune
      update_phone_call!(commune_code: selected_commune)
    end

    def update_contact
      contact = phone_call.contact
      commune_ids = contact.metadata.fetch("commune_ids", [])
      commune_ids << phone_call_metadata(:commune_code)
      contact.metadata = { "commune_ids" => commune_ids.uniq }
      contact.save!
    end

    def phone_call_metadata(key)
      phone_call.metadata.fetch(key.to_s)
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

    class AudioURL
      attr_reader :key, :region, :bucket

      def initialize(options)
        @key = options.fetch(:key)
        @region = options.fetch(:region, Rails.configuration.app_settings.fetch(:aws_region))
        @bucket = options.fetch(:bucket, Rails.configuration.app_settings.fetch(:audio_bucket))
      end

      def url
        "https://s3.#{region}.amazonaws.com/#{bucket}/#{key}"
      end
    end
  end
end
