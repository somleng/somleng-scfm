class ApplicationRequestSchema < Dry::Validation::Contract
  Types = FieldDefinitions::Types

  attr_reader :input_params

  option :resource, optional: true
  option :account, optional: true
  option :phone_number_validator, default: -> { PhoneNumberValidator.new }

  delegate :success?, :context, :errors, to: :result

  register_macro(:phone_number_format) do
    key.failure(text: "is invalid") if key? && !phone_number_validator.valid?(value)
  end

  register_macro(:url_format) do
    next unless value.present?

    uri = URI.parse(value)
    is_valid = (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.host.present?

    key.failure(text: "is invalid") unless is_valid
  rescue URI::InvalidURIError
    key.failure(text: "is invalid")
  end

  register_macro(:beneficiary_groups) do
    next unless key?

    next if account.beneficiary_groups.where(id: value.pluck(:id)).count == value.pluck(:id).size
    key.failure(text: "is invalid")
  end

  # NOTE: composable contracts
  #
  # params do
  #   required(:a).hash(OtherContract.schema)
  # end
  #
  # rule(:a).validate(contract: OtherContract)
  #
  register_macro(:contract) do |macro:|
    next unless key?

    contract_instance = macro.args[0]
    contract_result = contract_instance.new(input_params: value)
    unless contract_result.success?
      errors = contract_result.errors
      errors.each do |error|
        key(key.path.to_a + error.path).failure(error.text)
      end
    end
  end

  def initialize(input_params:, options: {})
    super(**options)

    @input_params = input_params.to_h.with_indifferent_access
  end

  def output
    result.to_h
  end

  private

  def result
    @result ||= call(input_params)
  end
end
