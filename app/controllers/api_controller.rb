class APIController < ActionController::API
  self.responder = JSONAPIResponder
  respond_to :json

  before_action :verify_requested_format!
  before_action :doorkeeper_authorize!

  rescue_from StatsQuery::TooManyResultsError do
    render json: { errors: [ { title:  "Too many results" } ] }, status: :bad_request
  end

  rescue_from JSONAPI::Serializer::UnsupportedIncludeError do |exception|
    render json: {
      errors: [
        {
          title:  "`#{exception.include_item}` is not in the list of supported relationships",
          source: { pointer: "/include" }
        }
      ]
    }, status: :bad_request
  end

  private

  def current_account
    @current_account ||= Account.find(doorkeeper_token&.resource_owner_id)
  end

  def respond_with_resource(resource, options = {})
    respond_with(:api, :v1, resource, **options)
  end

  def validate_request_schema(with:, **options)
    schema_options = options.delete(:schema_options) || {}
    input_params = options.delete(:input_params) || request.request_parameters
    schema_options[:account] = current_account

    schema = with.new(input_params:, options: schema_options)

    if schema.success?
      resource = yield(schema.output)

      location = options[:location]
      if location.respond_to?(:call) && location.arity == 1
        options[:location] = location.call(resource)
        respond_with_resource(resource, options)
      else
        respond_with_resource(resource, options)
      end
    else
      on_error = options.delete(:on_error)
      on_error&.call(schema)

      respond_with_errors(schema, **options)
    end
  end

  def apply_filters(scope, with:)
    validate_request_schema(
      with: with.filter_contract,
      input_params: request.query_parameters
    ) do |filter_group|
      FilterScope.new(scope:, filter_group:).apply
    end
  end

  def respond_with_errors(object, **)
    respond_with(object, responder: InvalidRequestSchemaResponder, **)
  end
end
