class BatchOperation::PhoneCallOperation < BatchOperation::Base
  DEFAULT_MAX_PER_PERIOD_HOURS = 24
  DEFAULT_MAX_PER_PERIOD_TIMESTAMP_ATTRIBUTE = "remotely_queued_at"

  MAX_PER_PERIOD_TIMESTAMP_ATTRIBUTES = [
    DEFAULT_MAX_PER_PERIOD_TIMESTAMP_ATTRIBUTE,
    "created_at",
    "updated_at"
  ]

  store_accessor :parameters,
                 :callout_filter_params,
                 :callout_participation_filter_params,
                 :skip_validate_preview_presence

  hash_store_reader   :callout_filter_params,
                      :callout_participation_filter_params

  store_accessor :parameters,
                 :max,
                 :max_per_period,
                 :max_per_period_hours,
                 :max_per_period_timestamp_attribute,
                 :max_per_period_statuses,
                 :limit

  integer_store_reader :max,
                       :max_per_period,
                       :max_per_period_hours,
                       :limit

  boolean_store_reader :skip_validate_preview_presence

  def calculate_limit
    [
      max,
      max_per_period && calls_remaining_in_period
    ].compact.min
  end

  def max_per_period_hours
    super || DEFAULT_MAX_PER_PERIOD_HOURS
  end

  def max_per_period_timestamp_attribute
    whitelisted(
      super,
      MAX_PER_PERIOD_TIMESTAMP_ATTRIBUTES
    ) || DEFAULT_MAX_PER_PERIOD_TIMESTAMP_ATTRIBUTE
  end

  private

  def split_values(value)
    value && value.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def whitelisted(value, list)
    Hash[list.map {|k| [k, k] }][value]
  end

  def calls_remaining_in_period
    [(max_per_period - calls_in_period.count), 0].max
  end

  def calls_in_period
    scope = PhoneCall.in_last_hours(max_per_period_hours, max_per_period_timestamp_attribute)
    scope = scope.where(:status => split_values(max_per_period_statuses)) if max_per_period_statuses
    scope
  end
end
