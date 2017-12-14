class CallFlowLogic::AvfCapom::CapomBase < CallFlowLogic::Base
  # Africa's Voices Foundation (AVF)
  # Cash Assistance Package Outcome Monitoring (CAPOM)

  DEFAULT_PLAY_FILE_EXTENSION = ".wav"
  DEFAULT_PLAY_FILE_BASE_URL = "https://s3-ap-southeast-1.amazonaws.com/scfm.unicef.io/call_flow_logic/avf_capom"

  attr_accessor :previous_status

  include AASM

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

  def twiml_for_gathering_safe_at_venue
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_fee_paid
    gather(:num_digits => 1)
  end

  def twiml_for_gathering_fee_paid_amount
    gather(:num_digits => 3)
  end

  def twiml_for_recording_goods_purchased
    play_and_record
  end

  def twiml_for_recording_transfer_not_received_reason
    play_and_record
  end

  def twiml_for_playing_transfer_not_received_exit_message
    play_and_hangup
  end

  def twiml_for_playing_completed_survey_message
    play_and_hangup
  end

  def twiml_for_finished
    voice_response do |response|
      response.hangup
    end
  end

  def play_and_record
    voice_response do |response|
      play_response_from_status(response)
      response.record
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
