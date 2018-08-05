class Filter::Params::CalloutParticipation
  ACCOUNT_SETTINGS_KEY = "batch_operation_phone_call_create_parameters".freeze
  CALLOUT_FILTER_PARAMS_KEY = "callout_filter_params".freeze
  CALLOUT_PARTICIPATION_FILTER_PARAMS_KEY = "callout_participation_filter_params".freeze

  attr_accessor :account
  attr_writer :callout_filter_params, :callout_participation_filter_params

  def initialize(account:, callout_filter_params: nil, callout_participation_filter_params: nil)
    self.account = account
    self.callout_filter_params = callout_filter_params
    self.callout_participation_filter_params = callout_participation_filter_params
  end

  def callout_filter_params
    @callout_filter_params || default_callout_filter_params
  end

  def callout_participation_filter_params
    @callout_participation_filter_params || default_callout_participation_filter_params
  end

  private

  def account_settings
    account.settings.fetch(ACCOUNT_SETTINGS_KEY) { {} }
  end

  def default_callout_filter_params
    account_settings.fetch(CALLOUT_FILTER_PARAMS_KEY, {})
  end

  def default_callout_participation_filter_params
    account_settings.fetch(CALLOUT_PARTICIPATION_FILTER_PARAMS_KEY, {})
  end
end
