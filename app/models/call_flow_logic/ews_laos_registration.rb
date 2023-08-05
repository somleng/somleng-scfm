module CallFlowLogic
  class EWSLaosRegistration < Base
    Province = Struct.new(:code, :iso3166, :name_en, :name_lo, keyword_init: true) do
      def full_name_en
        "#{name_en} Province"
      end

      def full_name_lo
        "ແຂວງ#{name_lo}"
      end
    end

    District = Struct.new(:code, :province, :name_en, :name_lo, keyword_init: true) do
      def address_en
        [full_name_en, province.full_name_en].join(", ")
      end

      def address_lo
        [full_name_lo, province.full_name_lo].join(" ")
      end

      def full_name_en
        "#{name_en} District"
      end

      def full_name_lo
        "ເມືອງ#{name_lo}"
      end
    end

    # https://en.wikipedia.org/wiki/Provinces_of_Laos
    SALAVAN = Province.new(code: "14", iso3166: "LA-AT", name_en: "Salavan", name_lo: "ສາລະວັນ")
    CHAMPASAK = Province.new(code: "16", iso3166: "LA-CH", name_en: "Champasak", name_lo: "ຈຳປາສັກ")
    ATTAPEU = Province.new(code: "17", iso3166: "LA-AT", name_en: "Attapeu", name_lo: "ອັດຕະປື")

    PROVINCE_MENU = [SALAVAN, CHAMPASAK, ATTAPEU].freeze

    # https://en.wikipedia.org/wiki/Districts_of_Laos
    DISTRICTS = [

      # Salavan
      District.new(code: "1401", name_en: "Saravane", name_lo: "ສາລະວັນ", province: SALAVAN),
      District.new(code: "1402", name_en: "Ta Oy", name_lo: "ຕະໂອ້ຍ", province: SALAVAN),
      District.new(code: "1403", name_en: "Toumlane", name_lo: "ຕຸ້ມລານ", province: SALAVAN),
      District.new(code: "1404", name_en: "Lakhonepheng", name_lo: "ລະຄອນເພັງ", province: SALAVAN),
      District.new(code: "1405", name_en: "Vapy", name_lo: "ວາປີ", province: SALAVAN),
      District.new(code: "1406", name_en: "Khongsedone", name_lo: "ຄົງເຊໂດນ", province: SALAVAN),
      District.new(code: "1407", name_en: "Lao Ngam", name_lo: "ເລົ່າງາມ", province: SALAVAN),
      District.new(code: "1408", name_en: "Sa Mouay", name_lo: "ສະມ້ວຍ", province: SALAVAN),

      # Champasak
      District.new(code: "1601", name_en: "Pakse", name_lo: "ປາກເຊ", province: CHAMPASAK),
      District.new(
        code: "1602",
        name_en: "Sanasomboun",
        name_lo: "ຊະນະສົມບູນ",
        province: CHAMPASAK
      ),
      District.new(
        code: "1603",
        name_en: "Batiengchaleunsouk",
        name_lo: "ບາຈຽງຈະເລີນສຸກ",
        province: CHAMPASAK
      ),
      District.new(code: "1604", name_en: "Paksong", name_lo: "ປາກຊ່ອງ", province: CHAMPASAK),
      District.new(code: "1605", name_en: "Pathouphone", name_lo: "ປະທຸມພອນ", province: CHAMPASAK),
      District.new(code: "1606", name_en: "Phonthong", name_lo: "ໂພນທອງ", province: CHAMPASAK),
      District.new(code: "1607", name_en: "Champassack", name_lo: "ຈຳປາສັກ", province: CHAMPASAK),
      District.new(code: "1608", name_en: "Soukhoumma", name_lo: "ສຸຂຸມາ", province: CHAMPASAK),
      District.new(
        code: "1609", name_en: "Mounlapamok", name_lo: "ມູນລະປະໂມກ",
        province: CHAMPASAK
      ),
      District.new(code: "1610", name_en: "Khong", name_lo: "ໂຂງ", province: CHAMPASAK),

      # Attapeu
      District.new(code: "1701", name_en: "Saysetha", name_lo: "ໄຊເຊດຖາ", province: ATTAPEU),
      District.new(code: "1702", name_en: "Samakkhixay", name_lo: "ສາມັກຄີໄຊ", province: ATTAPEU),
      District.new(code: "1703", name_en: "Sanamxay", name_lo: "ສະໜາມໄຊ", province: ATTAPEU),
      District.new(code: "1704", name_en: "Phouvong", name_lo: "ພູວົງ", province: ATTAPEU)
    ]

    INITIAL_STATUS = :answered

    attr_reader :voice_response

    include AASM

    aasm(column: :status, whiny_transitions: false) do
      state INITIAL_STATUS, initial: true
      state :playing_introduction
      state :gathering_province
      state :gathering_district
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
                    to: :playing_conclusion,
                    if: :district_gathered?,
                    after: %i[persist_district update_contact play_conclusion]

        transitions from: %i[gathering_province gathering_district],
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

    def play_conclusion
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(:registration_successful, response)
        response.redirect(current_url)
      end
    end

    def gather(&_block)
      Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true, &_block)
      end
    end

    def play(filename, response, language_code: "lao")
      key = ["ews_laos_registration/#{filename}", language_code].compact.join("-")
      response.play(url: AudioURL.new(key: "#{key}.wav").url)
    end

    def hangup
      @voice_response = Twilio::TwiML::VoiceResponse.new(&:hangup)
    end

    def start_over?
      dtmf_tones.to_s.first == "*"
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

    def selected_province
      return if pressed_digits.zero?

      PROVINCE_MENU[pressed_digits - 1]
    end

    def selected_district
      return if pressed_digits.zero?

      districts = DISTRICTS.find_all { |d| d.province.code == phone_call_metadata(:province_code) }
      districts.sort_by!(&:code)
      districts[pressed_digits - 1]
    end

    def persist_province
      update_phone_call!(
        province_code: selected_province.code,
        province_name_en: selected_province.name_en
      )
    end

    def persist_district
      update_phone_call!(
        district_code: selected_district.code,
        district_name_en: selected_district.name_en
      )
    end

    def update_contact
      contact = phone_call.contact
      district = DISTRICTS.find { |d| d.code == phone_call_metadata(:district_code) }
      contact.metadata = {
        "latest_district_id" => district.code,
        "latest_address_en" => district.address_en,
        "latest_address_lo" => district.address_lo
      }
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
  end
end
