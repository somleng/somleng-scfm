RSpec.shared_examples_for("phone_call_operation_batch_operation") do
  include_examples(
    "hash_store_accessor",
    :callout_filter_params,
    :callout_participation_filter_params
  )

  include_examples(
    "integer_store_reader",
    :max,
    :max_per_period,
    :limit
  )

  include_examples(
    "integer_store_reader",
    :max_per_period_hours,
    :default => BatchOperation::PhoneCallOperation::DEFAULT_MAX_PER_PERIOD_HOURS
  )

  include_examples(
    "json_store_accessor",
    "max_per_period_timestamp_attribute",
    :default => BatchOperation::PhoneCallOperation::DEFAULT_MAX_PER_PERIOD_TIMESTAMP_ATTRIBUTE
  )

  include_examples(
    "json_store_accessor",
    "max_per_period_statuses",
  )

  include_examples(
    "boolean_store_accessor",
    "skip_validate_preview_presence",
  )

  describe "associations" do
    it { is_expected.to have_many(:phone_calls).dependent(:restrict_with_error) }
  end

  describe "#calculate_limit" do
    it "returns nil by default" do
      subject = create(factory)

      result = subject.calculate_limit

      expect(result).to eq(nil)
    end

    it "returns max if specified" do
      subject = create(factory, max: "100")

      result = subject.calculate_limit

      expect(result).to eq(100)
    end

    it "returns max if max < max_per_period" do
      subject = create(factory, max: "100", max_per_period: "150")

      result = subject.calculate_limit

      expect(result).to eq(100)
    end

    it "returns max_per_period if max > max_per_period" do
      subject = create(factory, max: "100", max_per_period: "50")

      result = subject.calculate_limit

      expect(result).to eq(50)
    end

    it "calculates the limit based on the max calls allowed in 24 hours" do
      subject = create(factory, max_per_period: "50")
      create(:phone_call, :completed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :failed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :remotely_queued, remotely_queued_at: 24.hours.ago)

      result = subject.calculate_limit

      expect(result).to eq(48)
    end

    it "calcluates the limit based on the max calls allowed in 25 hours" do
      subject = create(factory, max_per_period: "50", max_per_period_hours: 25)
      create(:phone_call, :completed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :failed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :remotely_queued, remotely_queued_at: 24.hours.ago)

      result = subject.calculate_limit

      # all calls were remotely queued in the last 25 hours
      expect(result).to eq(47)
    end

    it "calculates the limit from the created_at attribute" do
      subject = create(
        factory, max_per_period: "50",
        max_per_period_hours: 24,
        max_per_period_timestamp_attribute: :created_at
      )
      create(:phone_call, :completed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :failed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :remotely_queued, remotely_queued_at: 24.hours.ago)

      result = subject.calculate_limit

      # all calls were created in the last 24 hours
      expect(result).to eq(47)
    end

    it "calculates the limit from the call status" do
      subject = create(
        factory, max_per_period: "50",
        max_per_period_hours: 24,
        max_per_period_statuses: :completed
      )
      create(:phone_call, :completed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :failed, remotely_queued_at: 23.hours.ago)
      create(:phone_call, :remotely_queued, remotely_queued_at: 24.hours.ago)

      result = subject.calculate_limit

      # 1 call was remotely queued and completed in the last 24 hours
      expect(result).to eq(49)
    end
  end
end
