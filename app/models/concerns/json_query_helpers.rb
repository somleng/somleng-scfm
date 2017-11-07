module JsonQueryHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def json_has_value(key, value, json_column)
      # Adapted from:
      # https://stackoverflow.com/questions/33432421/sqlite-json1-example-for-json-extract-set
      # http://guides.rubyonrails.org/active_record_postgresql.html#json

      value_condition = value.nil? ? "IS NULL" : "= ?"

      if database_adapter_helper.adapter_sqlite?
        sql = "json_extract(\"#{table_name}\".\"#{json_column}\", ?) #{value_condition}"
        key = "$.#{key}"
      else
        sql = "\"#{table_name}\".\"#{json_column}\" ->> ? #{value_condition}"
      end

      where(sql, *[key, value].compact)
    end

    def json_has_values(hash, json_column)
      scope = all
      hash.each do |k, v|
        scope = scope.json_has_value(k, v, json_column)
      end
      scope
    end
  end
end
