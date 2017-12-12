class Account < ApplicationRecord
  include MetadataHelpers
  has_many :users, :dependent => :restrict_with_error
end
