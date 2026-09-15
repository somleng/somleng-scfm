module V1
  class UpdateBroadcastRequestSchema < JSONAPIRequestSchema
    VALID_STATES = [ "running", "stopped" ].freeze

    option :broadcast_state_machine, default: -> { BroadcastStateMachine.new(resource.status) }

    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          optional(:audio_url).filled(:string)
          optional(:message).filled(:string)
          optional(:beneficiary_filter).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:target_areas).value(:hash).schema(TargetAreaSchema.schema)
          optional(:status).filled(included_in?: VALID_STATES)
          optional(:metadata).value(:hash)
        end

        optional(:relationships).value(:hash).schema do
          optional(:beneficiary_groups).value(:hash).schema do
            required(:data).value(:array, max_size?: Broadcast::MAX_BENEFICIARY_GROUPS).each do
              schema do
                required(:type).filled(:str?, eql?: "beneficiary_group")
                required(:id).filled(:int?)
              end
            end
          end
        end
      end
    end

    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:target_areas).validate(contract: TargetAreaSchema)
    attribute_rule(:audio_url).validate(:url_format)

    attribute_rule(:beneficiary_filter) do
      next unless key?
      next key.failure("cannot be updated after broadcast started") unless broadcast_state_machine.updatable?
      next key.failure("is not allowed") if resource.channel_capabilities.none?(&:deliverable?)
    end

    attribute_rule(:target_areas) do
      next unless key?
      next key.failure("cannot be updated after broadcast started") unless broadcast_state_machine.updatable?
    end

    attribute_rule(:audio_url) do
      next unless key?
      next key.failure("cannot be updated after broadcast started") unless broadcast_state_machine.updatable?
      next key.failure("is not allowed") if value.present? && resource.channel_capabilities.none?(&:audio?)
    end

    attribute_rule(:message) do
      next unless key?
      next key.failure("cannot be updated after broadcast started") unless broadcast_state_machine.updatable?
      next key.failure("is not allowed") if value.present? && resource.channel_capabilities.none?(&:text?)
    end

    attribute_rule(:status) do |context:, **|
      next unless key?

      if broadcast_state_machine.may_transition_to?(value)
        context[:desired_status] = broadcast_state_machine.transition_to!(value).name
        if value == "running" && resource.channel_capabilities.any?(&:deliverable?) && !account.configured_for_broadcasts?
          base.failure("Account not configured")
        end
      else
        key.failure("cannot transition from #{resource.status} to #{value}")
      end
    end

    relationship_rule(:beneficiary_groups).validate(:beneficiary_groups)
    relationship_rule(:beneficiary_groups) do
      next unless key?
      next key.failure("cannot be updated after broadcast started") unless broadcast_state_machine.may_transition_to?(:running)
      next key.failure("is not allowed") if resource.channel_capabilities.none?(&:deliverable?)
    end

    def output
      output_data = super
      result = output_data.slice(:audio_url, :message, :beneficiary_filter, :target_areas, :metadata)
      beneficiary_groups = output_data[:beneficiary_groups]
      result[:desired_status] = context.fetch(:desired_status) if context.key?(:desired_status)
      result[:beneficiary_group_ids] = beneficiary_groups if beneficiary_groups.present?
      result
    end
  end
end
