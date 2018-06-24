class Filter::Scope::Callout < Filter::Base
  def apply
    association_chain.joins(:callout).merge(callout_filter.resources)
  end

  def apply?
    callout_filter_params.present?
  end

  private

  def callout_filter
    Filter::Resource::Callout.new({ association_chain: Callout }, callout_filter_params)
  end

  def callout_filter_params
    params[:callout_filter_params]
  end
end
