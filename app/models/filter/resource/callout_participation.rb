class Filter::Resource::CalloutParticipation < Filter::Resource::Msisdn
  private

  def filter_params
    params.slice(:callout_id, :contact_id, :callout_population_id)
  end
end

