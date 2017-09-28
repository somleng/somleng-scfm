class ApplicationMigration < ActiveRecord::Migration[5.1]
  def json_column_type
    adapter_postgresql? ? :jsonb : :text
  end

  def json_column_default
    adapter_postgresql? ? {} : "{}"
  end

  def adapter_postgresql?
    ActiveRecord::Base.connection.adapter_name.downcase == "postgresql"
  end
end
