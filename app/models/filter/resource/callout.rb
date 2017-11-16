class Filter::Resource::Callout < Filter::Resource::Base
  private

  def filter_params
    params.slice(:status, :call_flow_logic)
  end
end

