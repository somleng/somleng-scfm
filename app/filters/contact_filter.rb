class ContactFilter < ApplicationFilter
  private

  def filter_params
    normalized_filter_params.slice(:msisdn)
  end

  def normalized_filter_params
    {
      :msisdn => PhonyRails.normalize_number(params[:msisdn]) || params[:msisdn]
    }.compact
  end
end

