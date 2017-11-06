class CalloutFilter < ApplicationFilter
  private

  def filter_params
    params.slice(:status)
  end
end

