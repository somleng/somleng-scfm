module API
  class RecordingsController < API::BaseController
    include ActiveStorage::SetCurrent
    include ActionController::MimeResponds

    respond_to :json, :mp3

    def show
      recording = find_resource

      respond_to do |format|
        format.json { respond_with_resource }
        format.mp3 { redirect_to(recording.audio_file.url, allow_other_host: true) }
      end
    end

    private

    def association_chain
      current_account.recordings
    end

    def filter_class
      Filter::Resource::Recording
    end
  end
end
