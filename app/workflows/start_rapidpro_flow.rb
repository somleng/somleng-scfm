class StartRapidproFlow
  attr_accessor :phone_call, :rapidpro_client

  def initialize(phone_call, options = {})
    self.phone_call = phone_call
    self.rapidpro_client = options.fetch(:rapidpro_client) {
      Rapidpro::Client.new(api_token: api_token)
    }
  end

  def call
    return if api_token.blank?
    return if flow_id.blank?
    return if phone_call.metadata.key?("rapidpro_flow_started_at")

    start_flow
  end

  private

  def start_flow
    phone_call.metadata["rapidpro_flow_started_at"] = Time.current.utc
    phone_call.save!

    response = rapidpro_client.start_flow(
      flow: flow_id,
      urns: ["tel:#{phone_call.msisdn}"]
    )

    phone_call.metadata["rapidpro_start_flow_response_status"] = response.status
    phone_call.metadata["rapidpro_start_flow_response_body"] = JSON.parse(response.body)

    phone_call.save!
  end

  def flow_id
    fetch_setting(:rapidpro_flow_id)
  end

  def api_token
    fetch_setting(:rapidpro_api_token)
  end

  def fetch_setting(key)
    callout_settings[key.to_s] || account_settings[key.to_s]
  end

  def callout_settings
    phone_call.callout&.settings || {}
  end

  def account_settings
    phone_call.account.settings
  end
end
