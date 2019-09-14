module Somleng
  module REST
    class Client < Twilio::REST::Client
      attr_accessor :api_host, :api_base_url

      def api
        @api ||= API.new(self)
      end
    end
  end
end
