class ContactRequestSchema < MetadataRequestSchema
  params do
    optional(:msisdn).filled(:string)
    optional(:metadata_fields_attributes).filled(:hash?)
  end

  rule(:msisdn).validate(:phone_number_format)

  rule do
    Rules.new(self).validate
  end

  def output
    result = super
    result[:msisdn] = PhonyRails.normalize_number(result.fetch(:msisdn)) if result.key?(:msisdn)
    result
  end

  class Rules < SchemaRules::ApplicationSchemaRules
    def validate
      return true if resource&.persisted?
      return key(:msisdn).failure(text: "can't be blank") if values[:msisdn].blank?

      key(:msisdn).failure(text: "must be unique") if contact_exists?
    end

    private

    def contact_exists?
      account.contacts.where_msisdn(values.fetch(:msisdn)).exists?
    end
  end
end
