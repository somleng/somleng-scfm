class FilterGroup
  attr_reader :conditions, :conjunction

  delegate :blank?, :empty?, to: :conditions

  def initialize(conditions: [], conjunction: :and)
    @conditions = conditions
    @conjunction = conjunction
  end

  def to_query(...)
    conditions.map { it.to_query(...) }.reduce(conjunction)
  end

  def associations
    conditions.flat_map(&:associations)
  end
end
