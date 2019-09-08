class ApplicationRequestSchema < Dry::Validation::Contract
  option :request

  delegate :success?, :errors, to: :result

  def output
    result.to_h
  end

  private

  def result
    @result ||= call(input_params)
  end

  def input_params
    request.request_parameters
  end
end
