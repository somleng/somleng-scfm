module Dashboard
  class BroadcastsController < DashboardController
    def index
      authorize(Broadcast)
      @filter_form = BroadcastFilterForm.new(filter_param)
      @broadcasts = paginate_resources(@filter_form.apply(scope))
    end

    def new
      @broadcast = BroadcastForm.new(account: current_account)
      authorize(@broadcast)
    end

    def create
      @broadcast = BroadcastForm.new(account: current_account, created_by: current_user, **permitted_params)
      authorize(@broadcast)
      @broadcast.save
      respond_with(:dashboard, @broadcast)
    end

    def edit
      @broadcast = BroadcastForm.initialize_with(find_broadcast)
    end

    def update
      @broadcast = BroadcastForm.new(
        account: current_account,
        object: find_broadcast,
        updated_by: current_user,
        **permitted_params
      )
      authorize(@broadcast)
      @broadcast.save

      respond_with(:dashboard, @broadcast)
    end

    def show
      @broadcast = BroadcastDecorator.new(find_broadcast)
    end

    def destroy
      @broadcast = find_broadcast
      @broadcast.destroy
      respond_with(:dashboard, @broadcast)
    end

    private

    def find_broadcast
      broadcast = scope.find(params[:id])
      authorize(broadcast)
      broadcast
    end

    def scope
      current_account.broadcasts
    end

    def permitted_params
      params.require(:broadcast).permit(
        :name,
        :audio_file,
        :message,
        :channel,
        :geocode_target_areas,
        beneficiary_groups: [],
        beneficiary_filter: {},
      )
    end
  end
end
