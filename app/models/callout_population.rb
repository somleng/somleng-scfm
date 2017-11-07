class CalloutPopulation < ApplicationRecord
  include MetadataHelpers
  conditionally_serialize(:contact_filter_params, JSON)
  belongs_to :callout

  def self.contact_filter_params_has_values(hash)
    json_has_values(hash, :contact_filter_params)
  end
end
