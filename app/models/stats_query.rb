class StatsQuery
  MAX_RESULTS = 10_000

  class TooManyResultsError < StandardError; end

  attr_reader :filter_group, :group_by

  def initialize(options)
    @filter_group = options[:filter_group]
    @group_by = options.fetch(:group_by)
  end

  def apply(scope)
    query = scope
    query = apply_filters(query) if filter_group.present?
    query = apply_aggregate(query)

    raise TooManyResultsError if total_count(query) > MAX_RESULTS

    query.count.map.with_index do |(key, value), index|
      StatResult.new(
        groups: group_by.map(&:name),
        key: Array(key),
        value:,
        sequence_number: index + 1
      )
    end
  end

  private

  def apply_filters(scope)
    FilterScope.new(scope:, filter_group:).apply
  end

  def apply_aggregate(scope)
    AggregateQuery.new(scope:, group_by:).apply
  end

  def total_count(query)
    ApplicationRecord.from(query.distinct(false).select("1").limit(MAX_RESULTS + 1)).count
  end
end
