class ApplicationMigration < ActiveRecord::Migration[5.1]
  def json_column_type
    database_adapter_helper.adapter_postgresql? ? :jsonb : :text
  end

  def json_column_default
    database_adapter_helper.adapter_postgresql? ? {} : "{}"
  end

  private

  def database_adapter_helper
    @database_adapter_helper ||= DatabaseAdapterHelper.new
  end
end
