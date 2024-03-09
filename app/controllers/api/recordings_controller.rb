module API
  class RecordingsController < API::BaseController
    private

    def association_chain
      current_account.recordings
    end

    def filter_class
      Filter::Resource::Recording
    end
  end
end
