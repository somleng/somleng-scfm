class FilterScope
  attr_reader :scope, :filter_group

  def initialize(scope:, filter_group:)
    @scope = scope
    @filter_group = filter_group
  end

  def apply
    scope.left_joins(joins_with).where(conditions).distinct
  end

  private

  def joins_with
    filter_group.conditions.flat_map(&:associations).compact_blank.uniq
  end

  def conditions
    filter_group.conditions.map { it.to_query(scope:) }.compact_blank.reduce(:and)
  end
end
