class CalloutPopulationFilter < ApplicationFilter
  def resources
    scope = super
    contact_filter_params.empty? ? scope : scope.merge(association_chain.contact_filter_params_has_values(contact_filter_params))
  end

  def contact_filter_params
    (params[:contact_filter_params] || {}).to_h
  end
end

