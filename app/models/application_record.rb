class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.database_adapter_helper
    @database_adapter_helper ||= DatabaseAdapterHelper.new
  end
end
