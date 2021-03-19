module BatchOperation
  class CalloutPopulation < Base
    include CustomRoutesHelper["batch_operations"]

    belongs_to :callout

    has_many :callout_participations,
             foreign_key: :callout_population_id,
             dependent: :restrict_with_error

    has_many :contacts, through: :callout_participations

    store_accessor :parameters,
                   :contact_filter_params,
                   :remote_request_params

    hash_store_reader :remote_request_params
    hash_store_reader :contact_filter_params

    accepts_nested_key_value_fields_for :contact_filter_metadata

    def run!
      contacts_scope.find_each do |contact|
        create_callout_participation(contact)
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
      ).resources
    end

    def create_callout_participation(contact)
      CalloutParticipation.create_or_find_by!(
        contact: contact,
        callout: callout
      ) do |callout_participation|
        callout_participation.callout_population = self
        callout_participation.phone_calls.build(
          account: callout.account,
          contact: contact,
        )
      end
    end

    def batch_operation_account_settings_param
      "batch_operation_callout_population_parameters"
    end
  end
end
