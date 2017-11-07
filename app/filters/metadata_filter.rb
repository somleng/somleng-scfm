class MetadataFilter < ApplicationFilter
  def resources
    association_chain.metadata_has_values(metadata)
  end

  def metadata
    params["metadata"] || {}
  end
end
