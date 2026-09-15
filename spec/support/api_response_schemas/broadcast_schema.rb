module APIResponseSchema
  BroadcastSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "broadcast")

    required(:attributes).schema do
      required(:name).maybe(:str?)
      required(:channels).array(:string).value(size?: 1).each do
        included_in?(Broadcast.channel.values)
      end
      required(:audio_url).maybe(:str?)
      required(:message).maybe(:str?)
      required(:beneficiary_filter).maybe(:hash?)
      required(:target_areas).maybe(:hash?)
      required(:metadata).maybe(:hash?)
      required(:status).filled(:str?)
      required(:error_code).maybe(:str?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end

    required(:relationships).schema do
      required(:beneficiary_groups).schema do
        required(:data).value(:array)
      end
    end
  end
end
