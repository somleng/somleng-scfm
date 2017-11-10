class Filter::Attribute::Metadata < Filter::Attribute::Base
  def apply
    association_chain.metadata_has_values(metadata)
  end

  def apply?
    metadata.any?
  end

  private

  def metadata
    (params[:metadata] || {}).to_h
  end
end
