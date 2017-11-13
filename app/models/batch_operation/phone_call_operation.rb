class BatchOperation::PhoneCallOperation < BatchOperation::Base
  json_attr_accessor :callout_filter_params,
                     :callout_participation_filter_params,
                     :json_attribute => :parameters

  hash_attr_reader   :callout_filter_params,
                     :callout_participation_filter_params,
                     :json_attribute => :parameters
end
