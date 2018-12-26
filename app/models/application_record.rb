class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include TimestampQueryHelpers
  include Rails6Backports unless respond_to?(:create_or_find_by)
end
