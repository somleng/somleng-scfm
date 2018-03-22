class Dashboard::CalloutsController < Dashboard::BaseController
  before_action :set_callout, only: [:show, :edit, :update, :destroy]

  def index
    @callouts = current_account.callouts.page(params[:page]).per(10)
  end

  def show; end

  def new
    @callout = Callout.new(metadata_forms: [MetadataForm.new])
  end

  def edit; end

  def create
    @callout = current_account.callouts.build(callout_params)

    if @callout.save(context: :dashboard)
      redirect_to dashboard_callout_url(@callout), notice: 'Callout was successfully created.'
    else
      render :new
    end
  end

  def update
    @callout.assign_attributes(callout_params)

    if @callout.save(context: :dashboard)
      redirect_to dashboard_callout_url(@callout), notice: 'Callout was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @callout.destroy

    redirect_to dashboard_callouts_url, notice: 'Callout was successfully destroyed.'
  end

  private

  def set_callout
    @callout = current_account.callouts.find(params[:id])
  end

  def callout_params
    params.require(:callout).permit(
      :id, metadata_forms_attributes: [:attr_key, :attr_val]
    )
  end
end
