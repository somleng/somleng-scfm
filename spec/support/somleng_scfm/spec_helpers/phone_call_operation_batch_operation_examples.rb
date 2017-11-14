RSpec.shared_examples_for("phone_call_operation_batch_operation") do
  include_examples(
    "hash_store_accessor",
    :callout_filter_params,
    :callout_participation_filter_params
  )
end

