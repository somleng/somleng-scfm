class AggregateQuery
  attr_reader :scope, :group_by

  def initialize(scope:, group_by:)
    @scope = scope
    @group_by = group_by
  end

  def apply
    scope.left_joins(joins_with).group(group_columns(scope))
  end

  private

  def joins_with
    group_by.map { it.query.association }.compact_blank.uniq
  end

  def group_columns(scope)
    group_by.map { it.query.arel_column || scope.arel_table[it.name] }
  end
end
