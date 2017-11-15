require 'rails_helper'

RSpec.describe BatchOperation::PhoneCallQueue do
  let(:factory) { :phone_call_queue_batch_operation }

  include_examples("batch_operation")
  include_examples("phone_call_operation_batch_operation")
  include_examples("phone_call_event_operation_batch_operation") do
    let(:asserted_status_after_run) { PhoneCall::STATE_QUEUED }
    let(:invalid_transition_status) { PhoneCall::STATE_QUEUED }
    let(:phone_call_factory_attributes) { {:status => PhoneCall::STATE_CREATED} }
  end
end
