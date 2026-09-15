class FieldQuery < Data.define(:association, :arel_column)
  def initialize(**)
    super(association: nil, arel_column: nil, **)
  end

  def to_arel(**)
    ArelBuilder.new(arel_column:, **).build
  end

  class ArelBuilder
    attr_reader :arel_column, :column_name, :operator, :value, :scope

    def initialize(arel_column:, column_name:, operator:, value:, scope:, **)
      @arel_column = arel_column
      @column_name = column_name
      @operator = operator.to_sym
      @value = value
      @scope = scope
    end

    def build
      column = arel_column.present? ? arel_column : scope.arel_table[column_name]
      column.public_send(operator_method, filter_value)
    end

    private

    # NOTE: cast from user input operator to arel attribute's predications
    # https://www.rubydoc.info/gems/arel/Arel/Predications
    def operator_method
      case operator
      when :eq, :not_eq, :gt, :gteq, :lt, :lteq, :between, :in, :not_in then operator
      when :contains, :starts_with then :matches
      when :not_contains then :does_not_match
      when :is_null then value ? :eq : :not_eq
      else
        raise ArgumentError, "Unsupported operator #{operator}"
      end
    end

    def filter_value
      case operator
      when :is_null then nil
      when :contains, :not_contains then Arel::Nodes::Quoted.new("%#{value}%")
      when :starts_with then Arel::Nodes::Quoted.new("#{value}%")
      when :between then Range.new(value[0], value[1])
      else value
      end
    end
  end
end
