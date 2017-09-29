class DatabaseAdapterHelper
  def json_column_type
    adapter_postgresql? ? :jsonb : :text
  end

  def json_column_default
    adapter_postgresql? ? {} : "{}"
  end

  def adapter_postgresql?
    adapter_name == "postgresql"
  end

  def adapter_sqlite?
    adapter_name == "sqlite"
  end

  private

  def adapter_name
    ActiveRecord::Base.connection.adapter_name.downcase
  end
end
