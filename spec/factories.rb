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
  end
end
