class SortParams
  SORT_KEY = :sort
  DESCENDING_PREFIX = "-".freeze
  DELIMETER = ",".freeze

  ORDER_DESCENDING = :desc
  ORDER_ASCENDING = :asc

  DEFAULT_ORDER_ATTRIBUTES = {
    created_at: ORDER_DESCENDING
  }.freeze

  attr_accessor :params, :sort_column, :sort_direction

  def initialize(params: {}, sort_column: nil, sort_direction: nil)
    self.params = params
    self.sort_column = sort_column
    self.sort_direction = sort_direction
  end

  def build_params
    return {} if sort_column.blank?
    {
      SORT_KEY => [
        (DESCENDING_PREFIX if sort_direction == ORDER_DESCENDING), sort_column
      ].compact.join("")
    }
  end

  def order_attributes
    @order_attributes ||= parse_params
  end

  def order_column
    order_attribute[0].to_sym
  end

  def order_direction
    order_attribute[1].to_sym
  end

  def toggle_order_direction
    order_direction == ORDER_ASCENDING ? ORDER_DESCENDING : ORDER_ASCENDING
  end

  private

  def parse_params
    return DEFAULT_ORDER_ATTRIBUTES if sort_params.empty?

    Hash[
      sort_params.split(DELIMETER).map do |sort_attribute|
        attribute = sort_attribute.delete_prefix(DESCENDING_PREFIX)
        order = attribute == sort_attribute ? ORDER_ASCENDING : ORDER_DESCENDING
        [attribute, order]
      end
    ]
  end

  def sort_params
    params.fetch(SORT_KEY, {})
  end

  def order_attribute
    order_attributes.first
  end
end
