module JsonQueryHelpers
  extend ActiveSupport::Concern

  class_methods do
    def json_has_value(keys, value, json_column)
      # Adapted from:
      # https://stackoverflow.com/questions/33432421/sqlite-json1-example-for-json-extract-set
      # http://guides.rubyonrails.org/active_record_postgresql.html#json

      keys = [keys].flatten

      value_condition = value.nil? ? "IS NULL" : "= ?"

      # From: https://www.postgresql.org/docs/current/static/functions-json.html
      # '{"a":[1,2,3],"b":[4,5,6]}'::json#>>'{a,2}' => 3
      # Note that the column is already jsonb so no need to cast
      key = "{#{keys.join(',')}}"
      sql = "\"#{table_name}\".\"#{json_column}\" #>> ? #{value_condition}"

      where(sql, *[key, value].compact)
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
  end
end
