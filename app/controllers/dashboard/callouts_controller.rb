class Dashboard::CalloutsController < Dashboard::BaseController
  before_action :set_callout, only: %i[show edit update destroy]

  def index
    @callouts = current_account.callouts.page(params[:page])
  end

  def show
    @commune = Pumi::Commune.find_by_id(@callout.commune_id)
  end

  def new
    @callout = current_account.callouts.build
  end

  def create
    @callout = current_account.callouts.build(callout_params)
    save_callout
    respond_with_callout
  end

  def update
    @callout.assign_attributes(callout_params)
    save_callout
    respond_with_callout
  end

  def destroy
    @callout.destroy
    respond_with_callout location: dashboard_callouts_path
  end

  private

  def save_callout
    @callout.save(context: :dashboard)
  end

  def respond_with_callout(location: nil)
    respond_with @callout, location: -> { location || dashboard_callout_path(@callout) }
  end

  def set_callout
    @callout = current_account.callouts.find(params[:id])
  end

  def callout_params
    params.require(:callout).permit(
      :voice, :province_id, :district_id, :commune_id
    )
  end
end
