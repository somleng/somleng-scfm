module Dashboard
  class RecordingsController < Dashboard::BaseController
    private

    def association_chain
      current_account.recordings
    end
  end
end
