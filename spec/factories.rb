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

    trait :running do
      status Callout::STATE_RUNNING
    end
  end

  factory :contact do
    msisdn { generate(:somali_msisdn) }
  end

  factory :callout_population do
    callout
  end

  factory :callout_participation do
    callout
    contact
  end

  factory :phone_call do
    contact

    transient do
      callout nil
    end

    after(:build) do |phone_call, evaluator|
      phone_call.callout_participation ||= build(
        :callout_participation,
        {
          :callout => evaluator.callout,
          :msisdn => phone_call.contact.msisdn,
        }.compact
      )
    end

    trait :not_recently_created do
      created_at { PhoneCall::DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS.seconds.ago }
    end

    trait :inbound do
      remote_direction { PhoneCall::TWILIO_DIRECTIONS[:inbound] }
    end
  end
end
