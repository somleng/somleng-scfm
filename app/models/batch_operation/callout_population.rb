module BatchOperation
  class CalloutPopulation < Base
    include CustomRoutesHelper["batch_operations"]

    belongs_to :callout

    has_many :callout_participations, dependent: :restrict_with_error

    has_many :contacts, through: :callout_participations

    store_accessor :parameters,
                   :contact_filter_params,
                   :remote_request_params

    hash_store_reader :remote_request_params
    hash_store_reader :contact_filter_params

    accepts_nested_key_value_fields_for :contact_filter_metadata

    validates :contact_filter_params, contact_filter_params: true

    def run!
      transaction do
        create_callout_participations
        create_phone_calls
      end
    end

    def contact_filter_metadata
      contact_filter_params.with_indifferent_access[:metadata] || {}
    end

    def contact_filter_metadata=(attributes)
      return if attributes.blank?

      self.contact_filter_params = { "metadata" => attributes }
    end

    private

    def contacts_scope
      Filter::Resource::Contact.new(
        { association_chain: account.contacts },
        contact_filter_params.with_indifferent_access
      ).resources.where.not(id: CalloutParticipation.select(:contact_id).where(callout:))
    end

    def create_callout_participations
      callout_participations = contacts_scope.find_each.map do |contact|
        {
          contact_id: contact.id,
          callout_id: callout.id,
          callout_population_id: id,
          msisdn: contact.msisdn,
          call_flow_logic: callout.call_flow_logic
        }
      end
      CalloutParticipation.upsert_all(callout_participations) if callout_participations.any?
    end

    def create_phone_calls
      phone_calls = callout_participations.includes(:phone_calls).find_each.map do |callout_participation|
        next if callout_participation.phone_calls.any?

        {
          account_id: callout.account_id,
          callout_id:,
          contact_id: callout_participation.contact_id,
          call_flow_logic: callout_participation.call_flow_logic,
          callout_participation_id: callout_participation.id,
          msisdn: callout_participation.msisdn,
          status: :created
        }
      end

      if phone_calls.any?
        PhoneCall.upsert_all(phone_calls)
        CalloutParticipation.where(id: phone_calls.pluck(:callout_participation_id)).update_all(phone_calls_count: 1)
      end
    end

    def batch_operation_account_settings_param
      "batch_operation_callout_population_parameters"
    end
  end
end
