FactoryBot.define do
  sequence :somali_msisdn, 252_662_345_678, &:to_s

  sequence :twilio_request_params do
    Hash[Twilio::REST::Client.new.api.account.calls.method(:create).parameters.map { |param| [param[1].to_s, param[1].to_s] }]
  end

  sequence :twilio_remote_call_event_details do
    {
      "CallSid" => SecureRandom.uuid,
      "From" => FactoryBot.generate(:somali_msisdn),
      "To" => "345",
      "CallStatus" => "completed",
      "Direction" => "inbound",
      "AccountSid" => SecureRandom.uuid,
      "ApiVersion" => "2010-04-01",
      "Digits" => "5"
    }
  end

  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :twilio_account_sid do |n|
    "#{Account::TWILIO_ACCOUNT_SID_PREFIX}#{n}"
  end

  sequence :auth_token do
    SecureRandom.uuid
  end

  sequence :somleng_account_sid do
    SecureRandom.uuid
  end

  factory :callout do
    account

    transient do
      audio_file nil
    end

    after(:build) do |callout, evaluator|
      if evaluator.audio_file.present?
        callout.audio_file = Rack::Test::UploadedFile.new(
          ActiveSupport::TestCase.fixture_path + "/files/#{evaluator.audio_file}",
          "audio/mp3"
        )
      end
    end

    trait :initialized do
    end

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
    account
    msisdn { generate(:somali_msisdn) }
  end

  factory :batch_operation_base, class: BatchOperation::Base do
    account

    trait :preview do
    end

    factory :callout_population, aliases: [:batch_operation], class: BatchOperation::CalloutPopulation do
      after(:build) do |callout_population|
        callout_population.callout ||= build(:callout, account: callout_population.account)
      end
    end

    factory :batch_operation_phone_call_operation, class: BatchOperation::PhoneCallOperation do
      skip_validate_preview_presence { true }

      factory :phone_call_create_batch_operation, class: BatchOperation::PhoneCallCreate do
        remote_request_params { generate(:twilio_request_params) }
      end

      factory :phone_call_queue_batch_operation, class: BatchOperation::PhoneCallQueue do
      end

      factory :phone_call_queue_remote_fetch_batch_operation, class: BatchOperation::PhoneCallQueueRemoteFetch do
      end
    end
  end

  factory :callout_participation do
    callout
    contact
  end

  factory :phone_call do
    outbound

    trait :with_default_provider do
      after(:build) do |phone_call|
        phone_call.contact ||= build(:contact, account: build(:account, :with_default_provider))
      end
    end

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
    transient do
      build_phone_call true
    end

    details { generate(:twilio_remote_call_event_details) }
    remote_call_id { details["CallSid"] }
    remote_direction { details["Direction"] }
    call_flow_logic { RemotePhoneCallEventObserver::DEFAULT_CALL_FLOW_LOGIC }

    after(:build) do |remote_phone_call_event, evaluator|
      if evaluator.build_phone_call
        remote_phone_call_event.phone_call ||= build(
          :phone_call,
          msisdn: remote_phone_call_event.details["From"],
          remote_call_id: remote_phone_call_event.remote_call_id,
          remote_direction: remote_phone_call_event.remote_direction
        )
      end
    end
  end

  factory :account do
    trait :with_default_provider do
      platform_provider_name "twilio"
      twilio_account_sid
      twilio_auth_token { generate(:auth_token) }
    end

    trait :super_admin do
      permissions [:super_admin]
    end
  end

  factory :user do
    account
    email
    password "secret123"
    password_confirmation { password }
  end

  factory :access_token do
    association :resource_owner, factory: :account
    created_by { resource_owner }
  end
end
