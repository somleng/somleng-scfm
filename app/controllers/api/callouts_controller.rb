class Api::CalloutsController < Api::BaseController
  private

  def association_chain
    Callout.all
  end

  def filter_class
    CalloutFilter
  end

  def permitted_filter_params_args
    super.prepend(:status)
  end
end
