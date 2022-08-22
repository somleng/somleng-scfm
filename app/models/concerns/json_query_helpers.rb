module JSONQueryHelpers
  extend ActiveSupport::Concern

  OPERATORS = {
    "in" => "in",
    "any" => "any",
    "lt" => "<",
    "lteq" => "<=",
    "gt" => ">",
    "gteq" => ">=",
    "exists" => "exists"
  }.freeze

  FIELD_TYPES = %w[numeric date].freeze

  class_methods do
    def json_has_value(keys, value, json_column_name)
      # Adapted from:
      # https://stackoverflow.com/questions/33432421/sqlite-json1-example-for-json-extract-set
      # http://guides.rubyonrails.org/active_record_postgresql.html#json

      key, field_type, operator = parse_keys(keys)
      json_column = "\"#{table_name}\".\"#{json_column_name}\""

      sql = if operator == "in" then "#{json_column} #>> :key IN (:value)"
            elsif operator == "any" then "(#{json_column} #>> :key)::JSONB ?| array[:value]"
            elsif value.nil? then "#{json_column} #>> :key IS NULL"
            elsif operator.in?(%w[lt lteq gt gteq])
              field_type ||= "numeric"
              operator = OPERATORS.fetch(operator)
              "(#{json_column}#>>:key)::#{field_type} #{operator} :value::#{field_type}"
            elsif operator == "exists"
              keys = key.split(",")
              key_field = keys.pop
              parent_keys = keys.map { |k| sanitize_sql([" -> ?", k]) }.join

              sql = sanitize_sql(
                [
                  "#{json_column}#{parent_keys} ? :key_field",
                  key_field: key_field
                ]
              )

              return ActiveModel::Type::Boolean.new.cast(value) ? where(sql) : where.not(sql)
            else
              "#{json_column} #>> :key = :value"
            end

      # From: https://www.postgresql.org/docs/current/static/functions-json.html
      # '{"a":[1,2,3],"b":[4,5,6]}'::json#>>'{a,2}' => 3
      # Note that the column is already jsonb so no need to cast
      value = value.is_a?(Array) ? value.map(&:to_s) : value.to_s
      where(sql, key: "{#{key}}", value: value)
    end

    def json_has_values(hash, json_column)
      flattened_hash = flatten_hash(hash)
      scope = all
      flattened_hash.each do |keys, v|
        scope = scope.json_has_value(keys, v, json_column)
      end
      scope
    end

    private

    # Adapted from:
    # https://stackoverflow.com/a/9648410
    def flatten_hash(hash, keys = [])
      return { keys => hash } unless hash.is_a?(Hash)

      hash.inject({}) { |h, v| h.merge! flatten_hash(v[-1], keys + [v[0]]) }
    end

    def parse_keys(keys)
      key = [keys].flatten.join(",")
      key_parts = key.split(".")

      operator = key_parts.pop if key_parts.last.in?(OPERATORS.keys)
      field_type = key_parts.pop if key_parts.last.in?(FIELD_TYPES)

      key = key_parts.join(".")

      [key, field_type, operator]
    end
  end
end
