class CallFlowLogic::OutcomeMonitoring < CallFlowLogic::Base
  DEFAULT_PLAY_FILE_EXTENSION = ".wav"
  DEFAULT_PLAY_FILE_BASE_URL = "http://example.com/voice"

  attr_accessor :previous_status

  include AASM

  aasm :whiny_transitions => false do
    state :initialized, :initial => true
    state :playing_introduction
    state :gathering_received_transfer
    state :gathering_received_transfer_amount
    state :recording_transfer_not_received_reason
    state :playing_transfer_not_received_exit_message
    state :finished
    state :gathering_paid_for_transport
    state :gathering_paid_for_transport_amount
    state :gathering_safe_at_venue
    state :gathering_fee_paid
    state :gathering_fee_paid_amount
    state :recording_goods_purchased
    state :gathering_item_availability
    state :gathering_idp_status
    state :gathering_water_availability
    state :gathering_sickness
    state :gathering_preferred_transfer_modality
    state :playing_completed_survey_message

    before_all_events :set_current_state
    after_all_events :set_status

    event :step do
      before :set_previous_status

      transitions :from => :initialized,
                  :to => :playing_introduction

      transitions :from => :playing_introduction,
                  :to =>   :gathering_received_transfer

      transitions :from => :gathering_received_transfer,
                  :to => :recording_transfer_not_received_reason,
                  :if => :answered_no?

      transitions :from => :recording_transfer_not_received_reason,
                  :to => :playing_transfer_not_received_exit_message

      transitions :from => :playing_transfer_not_received_exit_message,
                  :to => :finished

      transitions :from => :gathering_received_transfer,
                  :to => :gathering_received_transfer_amount,
                  :if => :answered_yes?

      transitions :from => :gathering_received_transfer_amount,
                  :to => :gathering_paid_for_transport,
                  :if => :answered_any?

      transitions :from => :gathering_paid_for_transport,
                  :to => :gathering_paid_for_transport_amount,
                  :if => :answered_yes?

      transitions :from => :gathering_paid_for_transport,
                  :to => :gathering_safe_at_venue,
                  :if => :answered_no?

      transitions :from => :gathering_paid_for_transport_amount,
                  :to => :gathering_safe_at_venue,
                  :if => :answered_any?

      transitions :from => :gathering_safe_at_venue,
                  :to => :gathering_fee_paid,
                  :if => :answered_yes_or_no?

      transitions :from => :gathering_fee_paid,
                  :to => :gathering_fee_paid_amount,
                  :if => :answered_yes?

      transitions :from => :gathering_fee_paid,
                  :to => :recording_goods_purchased,
                  :if => :answered_no?

      transitions :from => :gathering_fee_paid_amount,
                  :to => :recording_goods_purchased,
                  :if => :answered_any?

      transitions :from => :recording_goods_purchased,
                  :to => :gathering_item_availability

      transitions :from => :gathering_item_availability,
                  :to => :gathering_idp_status,
                  :if => :answered_yes_or_no?

      transitions :from => :gathering_idp_status,
                  :to => :gathering_water_availability,
                  :if => :answered_yes_or_no?

      transitions :from => :gathering_water_availability,
                  :to => :gathering_sickness,
                  :if => :answered_any?

      transitions :from => :gathering_sickness,
                  :to => :gathering_preferred_transfer_modality,
                  :if => :answered_yes_or_no?

      transitions :from => :gathering_preferred_transfer_modality,
                  :to => :playing_completed_survey_message,
                  :if => :answered_yes_or_no?

      transitions :from => :playing_completed_survey_message,
                  :to => :finished
    end
  end

  def run!
    super
    if step!
      before_save_contact
      contact.save
    end
  end

  def to_xml(options = {})
    respond_to?("twiml_for_#{status}", true) ? send("twiml_for_#{status}") : no_response
  end

  def status
    read_call_flow_data(:status)
  end

  def status=(status)
    write_call_flow_data(:status, status.to_s)
  end

  private

  def write_call_flow_data(key, value)
    call_flow_data = contact.metadata["call_flow_data"] ||= {}
    logic_call_flow_data = call_flow_data[self.class.to_s] ||= {}
    logic_call_flow_data[key.to_s] = value
  end

  def read_call_flow_data(key)
    ((contact.metadata["call_flow_data"] || {})[self.class.to_s] || {})[key.to_s]
  end

  def before_save_contact
    write_call_flow_data("transitioned_to_#{status}_by", event.id)
  end

  def set_previous_status
    @previous_status = aasm.current_state
  end

  def status_did_not_change?
    previous_status && previous_status == aasm.current_state
  end

  def digits
    event.details["Digits"]
  end

  def answered_yes?
    digits == "1"
  end

  def answered_no?
    digits == "2"
  end

  def answered_yes_or_no?
    answered_yes? || answered_no?
  end

  def answered_any?
    digits.present?
  end

  def contact
    event.contact
  end

  def twiml_for_initialized
    no_response
  end

  def twiml_for_playing_introduction
    play_and_redirect
  end

  def twiml_for_gathering_received_transfer
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_received_transfer_amount
    gather(:num_digits => 3)
  end

  def twiml_for_gathering_paid_for_transport
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_paid_for_transport_amount
    gather(:num_digits => 3)
  end

  def twiml_for_gathering_safe_at_venue
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_fee_paid
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_fee_paid_amount
    gather(:num_digits => 3)
  end

  def twiml_for_gathering_item_availability
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_idp_status
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_water_availability
    gather(:num_digits => 3)
  end

  def twiml_for_gathering_sickness
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_preferred_transfer_modality
    gather(:num_digits => 1)
  end

  def twiml_for_recording_goods_purchased
    play_and_record
  end

  def twiml_for_recording_transfer_not_received_reason
    play_and_record
  end

  def play_and_record
    voice_response do |response|
      play_response_from_status(response)
      response.record
    end
  end

  def twiml_for_playing_transfer_not_received_exit_message
    play_and_hangup
  end

  def twiml_for_playing_completed_survey_message
    play_and_hangup
  end

  def twiml_for_finished
    voice_response do |response|
      play_response(response, play_url_for(:survey_is_already_finished))
      response.hangup
    end
  end

  def gather(options = {}, &block)
    voice_response do |response|
      response.gather(default_gather_options.merge(options)) do |gather|
        if block_given?
          yield(gather)
        else
          play_response(gather, play_url_for(:did_not_understand_response)) if status_did_not_change?
        end
        play_response_from_status(gather)
      end
    end
  end

  def play_and_hangup
    voice_response do |response|
      play_response_from_status(response)
      response.hangup
    end
  end

  def play_and_redirect
    voice_response do |response|
      play_response_from_status(response)
      response.redirect(current_url)
    end
  end

  def voice_response(&block)
    Twilio::TwiML::VoiceResponse.new do |response|
      yield(response)
    end.to_s
  end

  def play_response_from_status(response)
    play_response(response, play_url_for(status))
  end

  def play_response(response, url)
    response.play(:url => url)
  end

  def play_url_for(filename)
    [play_file_base_url, filename.to_s + play_file_extension].join("/")
  end

  def play_file_extension
    ENV["CALL_FLOW_PLAY_FILE_EXTENSION"] || DEFAULT_PLAY_FILE_EXTENSION
  end

  def play_file_base_url
    ENV["CALL_FLOW_PLAY_FILE_BASE_URL"] || DEFAULT_PLAY_FILE_BASE_URL
  end

  def gather_timeout
    ENV["CALL_FLOW_GATHER_TIMEOUT"]
  end

  def default_gather_options
    {
      :timeout => gather_timeout
    }.compact
  end

  def set_current_state
    aasm.current_state = status && status.to_sym if status.present?
  end

  def set_status
    self.status = aasm.current_state
  end
end
