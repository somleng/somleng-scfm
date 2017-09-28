module HasMetadata
  extend ActiveSupport::Concern
  include ConditionalSerialization

  included do
    conditionally_serialize(:metadata, JSON)
  end

  module ClassMethods
    def metadata_has_value(key, value)
      # from:
      # https://stackoverflow.com/questions/33432421/sqlite-json1-example-for-json-extract-set
      # http://guides.rubyonrails.org/active_record_postgresql.html#json

      if ActiveRecord::Base.connection.adapter_name.downcase == "sqlite"
        where("json_extract(\"#{table_name}\".\"metadata\", ?) = ?", "$.#{key}", value)
      else
        where("\"#{table_name}\".\"metadata\" ->> ? = ?", key, value)
      end
    end
  end
end
