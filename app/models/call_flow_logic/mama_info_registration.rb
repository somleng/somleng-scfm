module CallFlowLogic
  class MamaInfoRegistration < Base
    # Call Flow
    #
    # Play introduction
    # Press 1 if pregnant, 2 if had your baby, 3 to listen again.
    # -> 1
    #   How many months pregnant?
    #   -> (1-9)
    #       Your baby is due in February 2023. Press 1 if correct, 2 if incorrect.
    #       -> 1
    #         Finished
    # -> 2
    #   How many months old is your baby?
    #   -> (1-24)
    #       Your baby was born in March 2022. Press 1 if correct, 2 if incorrect?
    #       -> 1
    #         Finished
    #
    # Already registered
    # Play introduction
    # Your already registered.
    # Your baby was born in March 2022. Press 1 to update your details or 2 to deregister.
    # Your baby is due in February 2023. Press 1 to update your details or 2 to deregister.
    # -> 1
    #  How many months pregnant?
    # -> 2
    #  You are now deregistered.
    #  Finished
    #
    # # Sound Files
    #
    # Format: "title-language_code"
    #
    # ## introduction-loz.mp3
    #
    # Hello! This is the registration portal of Mama Info service implemented by the
    # organization People in Need and supported by the Ministry of Health of Zambia.
    # Now, please pay attention to the instructions
    #
    # ## already_registered-loz.mp3
    #
    # Hello. You are already registered.
    #
    # gather_update_details_or_deregister-loz.mp3
    #
    # Press 1 to update your details or 2 to deregister.
    #
    # deregistration_successful-loz.mp3
    #
    # You are now deregistered.
    #
    # ## gather_mothers_status-loz.mp3
    #
    # If you are pregnant, please press 1.
    # If you have had your baby, please press 2.
    # If you want to listen to the instructions again, please press 3.
    #
    # ## gather_pregnancy_status-loz.mp3
    #
    # How many months pregnant are you? Enter the number of months on your keypad.
    #
    # ## confirm_pregnancy_status-loz.mp3
    #
    # Your baby is due in
    #
    # ## %{month}.mp3
    #
    # January -> December
    #
    # ## %{year}.mp3
    #
    # e.g. 2022
    #
    # ## gather_age-loz.mp3
    #
    # How many months old is your baby? Enter the number of months on your keypad.
    #
    # ## confirm_age-loz.mp3
    #
    # Your baby was born in
    #
    # ## registration_successful-loz.mp3
    #
    # Your registration to Mama Info service was successful.
    # You can now expect receiving voice recorded messages focused on good practices
    # in the fields of nutrition, health on regular basis. Thank you for your interest.
    #
    # ## confirm_input-loz.mp3
    #
    # Press 1 if correct. Press 2 if incorrect.
    #
    # ## invalid_response-loz.mp3
    #
    # We don’t quite understand your input, please try again.

    INITIAL_STATUS = :answered
    LANGUAGE_CODE = "loz".freeze # https://en.wikipedia.org/wiki/Lozi_language
    PREGNANT_RESPONSE = 1
    CHILD_BORN_RESPONSE = 2
    LISTEN_AGAIN_RESPONSE = 3
    CONFIRM_INPUT_RESPONSE = 1
    REGATHER_INPUT_RESPONSE = 2
    PREGNANCY_TERM = 9.months.freeze

    include AASM

    attr_reader :voice_response

    aasm(column: :status, whiny_transitions: false) do
      state INITIAL_STATUS, initial: true
      state :playing_introduction
      state :gathering_mothers_status

      state :playing_already_registered
      state :playing_registered_date_of_birth
      state :gathering_update_details_or_deregister
      state :playing_deregistered

      state :gathering_pregnancy_status
      state :confirming_pregnancy_status

      state :gathering_age
      state :confirming_age

      state :playing_registration_successful
      state :finished

      before_all_events :read_status
      after_all_events :persist_status

      event :process_call do
        transitions from: :answered,
                    to: :playing_introduction,
                    after: :play_introduction

        # Already registered flow
        transitions from: :playing_introduction,
                    to: :playing_already_registered,
                    if: :registered?,
                    after: :play_already_registered

        transitions from: :playing_already_registered,
                    to: :playing_registered_date_of_birth,
                    after: :play_registered_date_of_birth

        transitions from: :playing_registered_date_of_birth,
                    to: :gathering_update_details_or_deregister,
                    after: :gather_update_details_or_deregister

        transitions from: :gathering_update_details_or_deregister,
                    to: :gathering_mothers_status,
                    after: :gather_mothers_status,
                    if: :update_details?

        transitions from: :gathering_update_details_or_deregister,
                    to: :playing_deregistered,
                    after: %i[play_deregistration_successful persist_deregistered],
                    if: :deregister?

        transitions from: :playing_deregistered,
                    to: :finished,
                    after: :hangup

        # Unregistered flow
        transitions from: :playing_introduction,
                    to: :gathering_mothers_status,
                    after: :gather_mothers_status

        # Pregnant flow

        transitions from: :gathering_mothers_status,
                    to: :gathering_pregnancy_status,
                    if: :pregnant?,
                    after: :gather_pregnancy_status

        transitions from: :gathering_pregnancy_status,
                    to: :confirming_pregnancy_status,
                    if: :valid_pregnancy_status?,
                    after: %i[persist_unconfirmed_expected_date_of_birth confirm_pregnancy_status]

        transitions from: :confirming_pregnancy_status,
                    to: :playing_registration_successful,
                    if: :pregnancy_status_confirmed?,
                    after: %i[persist_date_of_birth play_registration_successful]

        transitions from: :confirming_pregnancy_status,
                    to: :gathering_pregnancy_status,
                    if: :regather_input?,
                    after: :gather_pregnancy_status

        # Child already born flow
        transitions from: :gathering_mothers_status,
                    to: :gathering_age,
                    if: :child_born?,
                    after: :gather_age

        transitions from: :gathering_age,
                    to: :confirming_age,
                    if: :valid_age?,
                    after: %i[persist_unconfirmed_date_of_birth confirm_age]

        transitions from: :confirming_age,
                    to: :playing_registration_successful,
                    if: :age_confirmed?,
                    after: %i[persist_date_of_birth play_registration_successful]

        transitions from: :confirming_age,
                    to: :gathering_age,
                    if: :regather_input?,
                    after: :gather_age

        transitions from: :playing_registration_successful,
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

    def play_introduction
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(:introduction, response)
        response.redirect(current_url)
      end
    end

    def play_already_registered
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(:already_registered, response)
        response.redirect(current_url)
      end
    end

    def gather_update_details_or_deregister
      @voice_response = gather do |response|
        play(:gather_update_details_or_deregister, response)
      end
    end

    def gather_mothers_status
      @voice_response = gather do |response|
        play(:gather_mothers_status, response)
      end
    end

    def gather_pregnancy_status
      @voice_response = gather do |response|
        play(:gather_pregnancy_status, response)
      end
    end

    def confirm_pregnancy_status
      confirm_date_of_birth do |response|
        play(:confirm_pregnancy_status, response)
      end
    end

    def gather_age
      @voice_response = gather do |response|
        play(:gather_age, response)
      end
    end

    def confirm_age
      confirm_date_of_birth do |response|
        play(:confirm_age, response)
      end
    end

    def play_registration_successful
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(:registration_successful, response)
        response.redirect(current_url)
      end
    end

    def play_registered_date_of_birth
      date_of_birth = Date.parse(metadata(phone_call.contact, :date_of_birth))

      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(date_of_birth.past? ? :confirm_age : :confirm_pregnancy_status, response)
        play(date_of_birth.strftime("%B").downcase, response)
        play(date_of_birth.year, response)
        response.redirect(current_url)
      end
    end

    def play_deregistration_successful
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(:deregistration_successful, response)
        response.redirect(current_url)
      end
    end

    def confirm_date_of_birth(&_block)
      unconfirmed_date_of_birth = metadata(phone_call, :unconfirmed_date_of_birth).to_date

      @voice_response = gather do |response|
        yield(response)
        play(unconfirmed_date_of_birth.strftime("%B").downcase, response)
        play(unconfirmed_date_of_birth.year, response)
        play(:confirm_input, response)
      end
    end

    def regather_invalid_input(&block)
      @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
        play(:invalid_response, response)
        response.gather(action_on_empty_result: true, &block)
      end
    end

    def hangup
      @voice_response = Twilio::TwiML::VoiceResponse.new(&:hangup)
    end

    def pregnant?
      validate_mothers_response?(PREGNANT_RESPONSE)
    end

    def child_born?
      validate_mothers_response?(CHILD_BORN_RESPONSE)
    end

    def registered?
      phone_call.contact.metadata["date_of_birth"].present?
    end

    def update_details?
      return true if pressed_digits == 1
      return false if pressed_digits == 2

      regather_invalid_input { |gather| play(:gather_update_details_or_deregister, gather) }
      false
    end

    def deregister?
      return true if pressed_digits == 2
      return false if pressed_digits == 1

      regather_invalid_input { |gather| play(:gather_update_details_or_deregister, gather) }
      false
    end

    def valid_pregnancy_status?
      return true if valid_input?(1..9)

      regather_invalid_input { |gather| play(:gather_pregnancy_status, gather) }
      false
    end

    def pregnancy_status_confirmed?
      input_confirmed? do
        regather_invalid_input { |gather| play(:confirm_pregnancy_status, gather) }
      end
    end

    def age_confirmed?
      input_confirmed? do
        regather_invalid_input { |gather| play(:confirm_age, gather) }
      end
    end

    def input_confirmed?(&_block)
      return true if pressed_digits == CONFIRM_INPUT_RESPONSE
      return false if regather_input?

      yield
      false
    end

    def validate_mothers_response?(menu_value)
      return false if listen_again?

      unless valid_input?(1..2)
        regather_invalid_input { |gather| play(:gather_mothers_status, gather) }
        return false
      end

      pressed_digits == menu_value
    end

    def listen_again?
      return false unless pressed_digits == LISTEN_AGAIN_RESPONSE

      gather_mothers_status
      true
    end

    def valid_age?
      return true if valid_input?(1..24)

      regather_invalid_input { |gather| play(:gather_age, gather) }
      false
    end

    def regather_input?
      pressed_digits == REGATHER_INPUT_RESPONSE
    end

    def valid_input?(range)
      range.member?(pressed_digits)
    end

    def persist_unconfirmed_expected_date_of_birth
      estimated_date_of_birth = (PREGNANCY_TERM - pressed_digits.months).from_now.beginning_of_month
      update_metadata!(phone_call, unconfirmed_date_of_birth: estimated_date_of_birth.to_date)
    end

    def persist_unconfirmed_date_of_birth
      estimated_date_of_birth = pressed_digits.months.ago.beginning_of_month
      update_metadata!(phone_call, unconfirmed_date_of_birth: estimated_date_of_birth.to_date)
    end

    def persist_date_of_birth
      date_of_birth = metadata(phone_call, :unconfirmed_date_of_birth)
      update_metadata!(phone_call, date_of_birth: date_of_birth)
      update_metadata!(phone_call.contact, date_of_birth: date_of_birth)
      phone_call.contact.metadata.delete("deregistered_at")
      phone_call.contact.save!
    end

    def persist_deregistered
      update_metadata!(phone_call.contact, deregistered_at: Time.current)
    end

    def play(filename, response)
      response.play(
        url: AudioURL.new(key: "mama_info_registration/#{filename}-#{LANGUAGE_CODE}.mp3").url
      )
    end

    def gather(&block)
      Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true, &block)
      end
    end

    def read_status
      aasm.current_state = phone_call.metadata.fetch("status", INITIAL_STATUS).to_sym
    end

    def persist_status
      update_metadata!(phone_call, status: aasm.to_state)
    end

    def update_metadata!(object, data)
      object.update!(metadata: object.metadata.deep_merge(data))
    end

    def dtmf_tones
      event.details["Digits"]
    end

    def pressed_digits
      dtmf_tones.to_i
    end

    def metadata(object, key)
      object.metadata.fetch(key.to_s)
    end
  end
end
