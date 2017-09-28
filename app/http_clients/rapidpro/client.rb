class Rapidpro::Client
  DEFAULT_BASE_URL = "https://app.rapidpro.io/api"
  DEFAULT_API_VERSION = "v2"
  DEFAULT_CONTENT_TYPE = "application/json"

  attr_accessor :base_url, :api_token, :api_version

  def initialize(options = {})
    self.base_url = options[:base_url]
    self.api_token = options[:api_token]
    self.api_version = options[:api_version]
  end

  def base_url
    @base_url || ENV["RAPIDPRO_BASE_URL"] || DEFAULT_BASE_URL
  end

  def api_version
    @api_version || ENV["RAPIDPRO_API_VERSION"] || DEFAULT_API_VERSION
  end

  def api_token
    @api_token || ENV["RAPIDPRO_API_TOKEN"]
  end

  def start_flow!(body = {}, headers = {})
    HTTParty.post(
      rapidpro_flow_starts_endpoint,
      :headers => default_headers.merge(headers),
      :body => body.to_json
    )
  end

  private

  def default_headers
    {
      "Authorization" => default_authorization_header,
      "Content-Type" => default_content_type
    }
  end

  def default_authorization_header
    "Token #{api_token}"
  end

  def default_content_type
    DEFAULT_CONTENT_TYPE
  end

  def rapidpro_flow_starts_endpoint
    rapidpro_endpoint("flow_starts")
  end

  def rapidpro_endpoint(path)
    "#{base_url}/#{api_version}/#{path}.json"
  end
end
