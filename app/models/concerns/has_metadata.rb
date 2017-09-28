module HasMetadata
  extend ActiveSupport::Concern
  include ConditionalSerialization

  included do
    conditionally_serialize(:metadata, JSON)
  end

  module ClassMethods
    def metadata_has_value(key, value)
      # Adapted from:
      # https://stackoverflow.com/questions/33432421/sqlite-json1-example-for-json-extract-set
      # http://guides.rubyonrails.org/active_record_postgresql.html#json

      value_condition = value.nil? ? "IS NULL" : "= ?"

      if ActiveRecord::Base.connection.adapter_name.downcase == "sqlite"
        sql = "json_extract(\"#{table_name}\".\"metadata\", ?) #{value_condition}"
        key = "$.#{key}"
      else
        sql = "\"#{table_name}\".\"metadata\" ->> ? #{value_condition}"
      end

      where(sql, *[key, value].compact)
    end
  end
end
