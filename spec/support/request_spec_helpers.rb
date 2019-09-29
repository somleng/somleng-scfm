module RequestSpecHelpers
  def build_authorization_headers(access_token:)
    { "HTTP_AUTHORIZATION" => encode_credentials(access_token: access_token) }
  end

  def encode_credentials(access_token:)
    ActionController::HttpAuthentication::Basic.encode_credentials(access_token.token, nil)
  end

  def set_authorization_header(access_token:)
    authentication :basic, "Bearer #{access_token.token}"
  end

  def build_batch_operation_request_body(parameters: {}, metadata: {}, **options)
    {
      metadata: {
        "foo" => "bar"
      }.merge(metadata),
      parameters: {
        "skip_validate_preview_presence" => "1"
      }.merge(parameters)
    }.merge(options)
  end

  def assert_batch_operation_created!(account:, request_body:)
    expect(response_status).to eq(201)
    parsed_response = JSON.parse(response_body)
    expect(parsed_response.fetch("metadata")).to eq(request_body.fetch(:metadata))
    expect(parsed_response.fetch("parameters")).to eq(request_body.fetch(:parameters))
    expect(
      account.batch_operations.find(parsed_response.fetch("id")).class
    ).to eq(request_body.fetch(:type).constantize)
  end
end

RSpec.configure do |config|
  config.include(RequestSpecHelpers, type: :request)
  config.include(RequestSpecHelpers, type: :job)
end
