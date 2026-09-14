FilterField = Data.define(:name, :operator, :value, :query, :metadata) do
  def initialize(**)
    super(metadata: {}, query: FieldQuery.new, **)
  end

  def to_query(**)
    query.to_arel(column_name: name, operator:, value:, **metadata, **)
  end

  def associations
    return [] if query.association.blank?

    [ query.association ]
  end
end
