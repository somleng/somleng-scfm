FactoryGirl.define do
  sequence :somali_msisdn, 252662345678 do |n|
    n.to_s
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
  end

  factory :contact do
  end

  factory :phone_number do
    callout
    contact
    msisdn { generate(:somali_msisdn) }
  end

  factory :phone_call do
    transient do
      callout nil
    end

    after(:build) do |phone_call, evaluator|
      phone_call.phone_number ||= build(:phone_number, {:callout => evaluator.callout}.compact)
    end

    trait :not_recently_created do
      created_at { PhoneCall::DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS.seconds.ago }
    end
  end
end
