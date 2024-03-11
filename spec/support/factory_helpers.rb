module FactoryHelpers
  def create_callout_participation(account:, **options)
    callout = options.delete(:callout) || create(:callout, account:)
    contact = options.delete(:contact) || create(:contact, account:)
    create(:callout_participation, { callout:, contact: }.merge(options))
  end

  def create_phone_call(*args)
    options = args.extract_options!
    account = options.delete(:account)
    raise(ArgumentError, "Missing account") if account.blank?

    callout_participation = options.delete(:callout_participation) || create_callout_participation(account:)
    create(
      :phone_call, *args,
      account:, callout_participation:,
      **options
    )
  end

  def create_remote_phone_call_event(account:, **options)
    phone_call = options.delete(:phone_call) || create_phone_call(account:)
    create(:remote_phone_call_event, phone_call:, **options)
  end
end

RSpec.configure do |config|
  config.include(FactoryHelpers)
end
