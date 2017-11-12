class BatchOperation::PhoneCallCreate < BatchOperation::Base
  validates :remote_request_params,
            :twilio_request_params => true,
            :presence => true

  hash_attr_accessor :remote_request_params,
                     :callout_filter_params,
                     :attribute => :parameters
end
