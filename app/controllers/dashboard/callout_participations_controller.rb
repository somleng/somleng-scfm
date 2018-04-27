class Dashboard::CalloutParticipationsController < Dashboard::BaseController
  def new
    @callout_participation = callout.callout_participations.build
  end

  def create
    @callout_participation =
      callout.callout_participations.build(callout_participation_params)

    if @callout_participation.save
      redirect_to dashboard_callout_url(@callout_participation.callout), notice: 'Callout participation was successfully created.'
    else
      render :new
    end
  end

  private

  def callout
    @callout ||= current_account.callouts.find(params[:callout_id])
  end

  def callout_participation_params
    params.require(:callout_participation).permit(:id, :contact_id)
  end
end
