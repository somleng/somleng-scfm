require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "Somleng SCFM API Documentation"
  config.api_explanation = <<~HEREDOC
    This is the API Documentation for Somleng Simple Call Flow Manager (Somleng SCFM).
  HEREDOC
  config.format = :slate
  config.curl_host = "https://scfm.somleng.org"
  config.curl_headers_to_filter = ["Host", "Cookie", "Content-Type"]

  config.request_headers_to_include = []
  config.response_headers_to_include = ["Location", "Per-Page", "Total"]
  config.request_body_formatter = proc do |params|
    JSON.pretty_generate(params) if params.present?
  end
  config.keep_source_order = false
  config.disable_dsl_status!
end
