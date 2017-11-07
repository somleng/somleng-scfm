class CalloutPopulationFilter < ApplicationFilter
  def resources
    super.merge(association_chain.contact_filter_params_has_values(contact_filter_params))
  end

  def contact_filter_params
    params[:contact_filter_params] || {}
  end
end

