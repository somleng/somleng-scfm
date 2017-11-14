class BatchOperation::PhoneCallOperation < BatchOperation::Base
  store_accessor :parameters,
                 :callout_filter_params,
                 :callout_participation_filter_params

  hash_store_reader   :callout_filter_params,
                      :callout_participation_filter_params
end
