class UpdateBroadcast < ApplicationWorkflow
  class InvalidStateTransitionError < StandardError; end

  attr_reader :broadcast, :desired_status, :params

  def initialize(broadcast, desired_status: nil, **params)
    super()
    @broadcast = broadcast
    @desired_status = desired_status
    @params = params
  end

  def call
    broadcast.transaction do
      broadcast.update!(params)
      update_target_areas if params.key?(:target_areas)
      if desired_status.present?
        broadcast.transition_to!(desired_status)

        if params[:updated_by].present?
          broadcast.update!(started_by: params[:updated_by]) if broadcast.queued?
          broadcast.update!(stopped_by: params[:updated_by]) if broadcast.stopped?
        end
      end
    end

    if broadcast.queued?
      ExecuteWorkflowJob.perform_later(StartBroadcast.to_s, broadcast)
    else
      CreateEvent.call(type: "broadcast.updated", resource: broadcast)
    end

    broadcast
  rescue ::StateMachine::Machine::InvalidStateTransitionError => e
    raise InvalidStateTransitionError, e.message
  end

  private

  def update_target_areas
    GeocodeTargetArea.where(broadcast_id: broadcast.id).delete_all
    GeocodeTargetArea.insert_all(build_geocode_target_area_records, unique_by: [ :broadcast_id, :path ])
  end

  def build_geocode_target_area_records
    BuildGeocodeTargetAreaRecords.call(broadcast.target_areas.geocode, locality_data:).map { it.merge(broadcast_id: broadcast.id) }
  end

  def locality_data
    CountryLocalityData.locality_data(broadcast.account.iso_country_code).collection
  end
end
