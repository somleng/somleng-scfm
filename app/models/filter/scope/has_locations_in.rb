class Filter::Scope::HasLocationsIn < Filter::Base
  def apply
    association_chain.has_locations_in(commune_ids_params)
  end

  def apply?
    commune_ids_params.present?
  end

  private

  def commune_ids_params
    params[:has_locations_in]
  end
end
