class Api::CalloutStatisticsController < Api::AuthenticatedController
  respond_to :json

  private

  def find_resource
    @resource = CalloutStatistics.new(:callout => callout)
  end

  def callout
    @callout ||= Callout.find(params[:callout_id])
  end
end
