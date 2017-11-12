FactoryGirl.define do
  sequence :somali_msisdn, 252662345678 do |n|
    n.to_s
  end

  sequence :twilio_request_params do
    Hash[Somleng::Client.new.api.account.calls.method(:create).parameters.map { |param| [param[1].to_s, param[1].to_s] }]
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

    factory :phone_call_create_batch_operation, :class => BatchOperation::PhoneCallCreate do
      remote_request_params { generate(:twilio_request_params) }
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

    trait :not_recently_created do
      created_at { PhoneCall::DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS.seconds.ago }
    end

    trait :inbound do
      remote_direction { PhoneCall::TWILIO_DIRECTIONS[:inbound] }
    end
  end
end
