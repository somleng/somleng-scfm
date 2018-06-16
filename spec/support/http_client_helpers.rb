module HTTPClientHelpers
  def authorization_header(request:)
    Base64.decode64(request.headers.fetch("Authorization").sub(/^Basic\s/, ""))
  end

  def request_body(request:)
    WebMock::Util::QueryMapper.query_to_values(request.body)
  end
end

RSpec.configure do |config|
  config.include(HTTPClientHelpers, type: :job)
end
