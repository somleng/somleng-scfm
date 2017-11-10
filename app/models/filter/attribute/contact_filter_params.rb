class Filter::Attribute::ContactFilterParams < Filter::Attribute::Base
  def apply
    association_chain.contact_filter_params_has_values(contact_filter_params)
  end

  def apply?
    contact_filter_params.any?
  end

  private

  def contact_filter_params
    (params[:contact_filter_params] || {}).to_h
  end
end
