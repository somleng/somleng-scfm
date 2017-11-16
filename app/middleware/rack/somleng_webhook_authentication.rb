class Rack::SomlengWebhookAuthentication < Rack::TwilioWebhookAuthentication
  def initialize(app, auth_token, *paths, &auth_token_lookup)
    options = paths.extract_options!
    @methods = [options[:methods]].compact.flatten.map { |method| method.to_s.upcase }
    super
  end

  def call(env)
    return @app.call(env) if @methods.any? && !@methods.include?(Rack::Request.new(env).request_method)
    super
  end
end
