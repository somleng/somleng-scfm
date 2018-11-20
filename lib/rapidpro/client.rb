module Rapidpro
  class Client
    DEFAULT_API_HOST = "https://app.rapidpro.io".freeze
    DEFAULT_API_VERSION = "v2".freeze
    CONTENT_TYPE = "application/json".freeze

    attr_accessor :api_host, :api_token, :api_version

    def initialize(options = {})
      self.api_token = options.fetch(:api_token)
      self.api_host = options.fetch(:api_host) { DEFAULT_API_HOST }
      self.api_version = options.fetch(:api_version) { DEFAULT_API_VERSION }
    end

    def start_flow(body = {}, headers = {})
      http_client.post(
        rapidpro_endpoint(:flow_starts),
        body.to_json,
        headers.reverse_merge(default_headers)
      )
    end

    private

    def default_headers
      {
        "Authorization" => "Token #{api_token}",
        "Content-Type" => CONTENT_TYPE
      }
    end

    def rapidpro_endpoint(path)
      "#{api_host}/api/#{api_version}/#{path}.json"
    end

    def http_client
      @http_client ||= Faraday.new(url: api_host)
    end
  end
end
