class Filter::Attribute::Duration < Filter::Attribute::Base
  VALID_COMPARATORS = %i[gt gteq lt lteq].freeze

  def apply
    scope = association_chain.all
    sanitize_query_params.each do |comparator, value|
      scope = scope.where(scope.arel_table[duration_column].public_send(comparator, value))
    end
    scope
  end

  def apply?
    sanitize_query_params.any?
  end

  private

  def duration_column
    options.fetch(:duration_column)
  end

  def sanitize_query_params
    VALID_COMPARATORS.each_with_object({}) do |comparitor, sanitized_params|
      sanitized_params[comparitor] = params[:"#{duration_column}_#{comparitor}"]
    end.compact
  end
end
