FactoryGirl.define do
  sequence :somali_msisdn, 252662345678 do |n|
    n.to_s
  end

  sequence :twilio_request_params do
    Hash[Somleng::Client.new.api.account.calls.method(:create).parameters.map { |param| [param[1].to_s, param[1].to_s] }]
  end

  sequence :twilio_remote_call_event_details do
    {
      "CallSid" => SecureRandom.uuid,
      "From" => FactoryGirl.generate(:somali_msisdn),
      "To" => "345",
      "CallStatus" => "completed",
      "Direction" => "inbound",
      "AccountSid" => SecureRandom.uuid,
      "ApiVersion" => "2010-04-01",
      "Digits" => "5"
    }
  end

  factory :callout do
    trait :can_start do
    end

    trait :can_stop do
      status "running"
    end

    trait :can_pause do
      can_stop
    end

    trait :can_resume do
      status "paused"
    end

    trait :running do
      status Callout::STATE_RUNNING
    end
  end

  factory :contact do
    msisdn { generate(:somali_msisdn) }
  end

  factory :batch_operation_base, :class => BatchOperation::Base do
    factory :callout_population, :aliases => [:batch_operation], :class => BatchOperation::CalloutPopulation do
      callout
    end

    factory :batch_operation_phone_call_operation, :class => BatchOperation::PhoneCallOperation do
      skip_validate_preview_presence { true }

      factory :phone_call_create_batch_operation, :class => BatchOperation::PhoneCallCreate do
        remote_request_params { generate(:twilio_request_params) }
      end

      factory :phone_call_queue_batch_operation, :class => BatchOperation::PhoneCallQueue do
      end

      factory :phone_call_queue_remote_fetch_batch_operation, :class => BatchOperation::PhoneCallQueueRemoteFetch do
      end
    end
  end

  factory :callout_participation do
    callout
    contact
  end

  factory :phone_call do
    outbound

    trait :outbound do
      callout_participation
      remote_request_params { generate(:twilio_request_params) }
    end

    trait :inbound do
      callout_participation nil
      remote_request_params { {} }
      msisdn { generate(:somali_msisdn) }
      remote_direction { PhoneCall::TWILIO_DIRECTIONS[:inbound] }
    end
  end

  factory :remote_phone_call_event do
    details { generate(:twilio_remote_call_event_details) }
  end
end
