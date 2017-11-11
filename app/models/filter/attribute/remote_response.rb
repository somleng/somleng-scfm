class Filter::Attribute::RemoteResponse < Filter::Attribute::Base
  def apply
    association_chain.remote_response_has_values(remote_response_params)
  end

  def apply?
    remote_response_params.any?
  end

  private

  def remote_response_params
    (params[:remote_response] || {}).to_h
  end
end
