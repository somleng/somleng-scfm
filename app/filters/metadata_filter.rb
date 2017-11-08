class MetadataFilter < ApplicationFilter
  def resources
    metadata.empty? ? association_chain : association_chain.metadata_has_values(metadata)
  end

  def metadata
    (params[:metadata] || {}).to_h
  end
end
