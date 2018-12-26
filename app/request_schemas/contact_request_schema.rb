ContactRequestSchema = Dry::Validation.Params(ApplicationRequestSchema) do
  configure do
    option :resource, Contact
    option :account, Account

    def unique?(value)
      account.contacts.where.not(id: resource.id).where_msisdn(value).empty?
    end
  end

  optional(:msisdn, ApplicationRequestSchema::Types::PhoneNumber).filled(:phone_number?, :unique?)

  rule(require_msisdn: [:msisdn]) do |msisdn|
    create?.then(msisdn.filled?)
  end

  optional(:metadata, :hash).filled(:hash?)
  optional(:metadata_merge_mode, :string).filled(:str?, included_in?: metadata_merge_modes)
  optional(:metadata_fields_attributes, :hash).filled(:hash?)
end
