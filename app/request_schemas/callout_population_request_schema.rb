class CalloutPopulationRequestSchema < MetadataRequestSchema
  params do
    optional(:type).filled(:string, eql?: "BatchOperation::CalloutPopulation")
    optional(:parameters).maybe(:hash?).schema do
      optional(:contact_filter_params).maybe(:hash?)
    end
  end

  rule(:type) do
    key.add("is blank") if resource.blank? && value.blank?
  end

  rule(parameters: :contact_filter_params) do
    next unless key?

    Filter::Resource::Contact.new(
      { association_chain: Contact.all },
      value
    ).resources.any?
  rescue ActiveRecord::StatementInvalid
    key.failure("is invalid")
  end
end
