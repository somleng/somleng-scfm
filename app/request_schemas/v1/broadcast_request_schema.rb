module V1
  class BroadcastRequestSchema < JSONAPIRequestSchema
    option :broadcast_state_machine, default: -> { BroadcastStateMachine.new }

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          optional(:channels).array(:string).value(size?: 1).each do
            included_in?(Broadcast.channel.values)
          end
          optional(:channel).maybe(:str?)
          optional(:audio_url).maybe(:str?)
          optional(:message).maybe(:str?)
          optional(:beneficiary_filter).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:target_areas).filled(:hash).schema(TargetAreaSchema.schema)
          optional(:status).filled(:str?, eql?: "running")
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

    attribute_rule(:channel) do |context:, **|
      next if value != "voice"

      context[:channels] = Array("voice_call")
      context[:channel_capabilities] = context[:channels].map { BroadcastChannelCapabilities.new(it) }
    end

    attribute_rule(:channels) do |attributes:, context:, **|
      context[:channels] = Array(attributes[:channels]) if key?
      context[:channel_capabilities] = Array(context[:channels]).map { BroadcastChannelCapabilities.new(it) }
      key.failure("is required") if Array(context[:channels]).blank?
      key.failure("is not supported") if Array(context[:channels]).any? { account.supported_channels.exclude?(it) }
    end

    attribute_rule(:status) do |context:, **|
      next unless key?

      if Array(context[:channel_capabilities]).any?(&:deliverable?) && !account.configured_for_broadcasts?
        base.failure("Account not configured")
      end
    end

    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:target_areas).validate(contract: TargetAreaSchema)

    attribute_rule(:beneficiary_filter) do |attributes:, relationships:, context:, **|
      next if context[:channel_capabilities].blank?

      if context[:channel_capabilities].any?(&:deliverable?)
        next if key?
        next if relationships.key?(:beneficiary_groups)
        next if attributes[:target_areas].present?

        key.failure("is missing")
      else
        key.failure("is not allowed") if key?
      end
    end

    attribute_rule(:audio_url) do |context:, **|
      next key.failure("is missing") if value.blank? && Array(context[:channel_capabilities]).any?(&:audio?)
      next key.failure("is not allowed") if value.present? && Array(context[:channel_capabilities]).none?(&:audio?)
    end

    attribute_rule(:message) do |context:, **|
      next key.failure("is missing") if value.blank? && Array(context[:channel_capabilities]).any?(&:text?)
      next key.failure("is not allowed") if value.present? && Array(context[:channel_capabilities]).none?(&:text?)
    end

    attribute_rule(:audio_url).validate(:url_format)

    relationship_rule(:beneficiary_groups).validate(:beneficiary_groups)

    relationship_rule(:beneficiary_groups) do |context:, **|
      next if context[:channel_capabilities].blank?

      key.failure("is not allowed") if key? && context[:channel_capabilities].none?(&:deliverable?)
    end

    def output
      output_data = super
      result = output_data.slice(:message, :audio_url, :beneficiary_filter, :target_areas, :metadata)
      result[:channel] = context[:channels].first
      result[:beneficiary_group_ids] = Array(output_data[:beneficiary_groups])
      result[:desired_status] = broadcast_state_machine.transition_to!(output_data.fetch(:status)).name if output_data.key?(:status)
      result[:created_via] = :api
      result
    end
  end
end
