module BatchOperation
  class PhoneCallCreate < BatchOperation::PhoneCallOperation
    include CustomRoutesHelper["batch_operations"]

    has_many :phone_calls,
             class_name: "PhoneCall",
             foreign_key: :create_batch_operation_id,
             dependent: :restrict_with_error

    has_many :contacts, through: :phone_calls
    has_many :callout_participations, through: :phone_calls

    validates :remote_request_params,
              twilio_request_params: true,
              presence: true

    validates :callout_participations_preview,
              presence: true,
              unless: :skip_validate_preview_presence?

    store_accessor :parameters, :remote_request_params
    hash_store_reader :remote_request_params

    def run!
      # Using find_each here will override the random order
      callout_participations_preview.each do |callout_participation|
        create_phone_call(callout_participation)
      end
    end

    def callout_participations_preview
      preview.callout_participations(
        scope: account.callout_participations
      ).order(Arel.sql("RANDOM()")).limit(applied_limit)
    end

    def contacts_preview
      preview.contacts(scope: account.contacts).limit(applied_limit)
    end

    private

    def applied_limit
      limit || calculate_limit
    end

    def preview
      Preview::PhoneCallCreate.new(previewable: self)
    end

    def create_phone_call(callout_participation)
      PhoneCall.create(
        callout_participation: callout_participation,
        contact: callout_participation.contact,
        create_batch_operation: self,
        remote_request_params: remote_request_params
      )
    end

    def batch_operation_account_settings_param
      Filter::Params::CalloutParticipation::ACCOUNT_SETTINGS_KEY
    end
  end
end
