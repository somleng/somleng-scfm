FactoryGirl.define do
  sequence :somali_msisdn, 252662345678 do |n|
    n.to_s
  end

  factory :callout do
  end

  factory :phone_number do
    callout
    msisdn { generate(:somali_msisdn) }
  end

  factory :phone_call do
    phone_number

    trait :not_recently_created do
      created_at { PhoneCall::DEFAULT_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS.seconds.ago }
    end
  end
end
