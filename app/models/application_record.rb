class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include TimestampQueryHelpers

  if respond_to?(:create_or_find_by)
    warn("'create_or_find_by' is already defined by Rails!")
  else
    include Rails6Backports
  end
end
