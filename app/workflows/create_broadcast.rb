class CreateBroadcast < ApplicationWorkflow
  attr_reader :desired_status, :params

  def initialize(desired_status: nil, **params)
    super()
    @desired_status = desired_status
    @params = params
  end

  def call
    Broadcast.transaction do
      broadcast = Broadcast.create!(params)
      broadcast.transition_to!(desired_status) if desired_status.present?
      GeocodeTargetArea.insert_all(
        build_geocode_target_area_records(broadcast),
        unique_by: [ :broadcast_id, :path ]
      )
      ExecuteWorkflowJob.perform_later(StartBroadcast.to_s, broadcast) if broadcast.queued?
      CreateEvent.call(type: "broadcast.created", resource: broadcast)
      broadcast
    end
  end

  private

  def build_geocode_target_area_records(broadcast)
    locality_data = CountryLocalityData.locality_data(broadcast.account.iso_country_code).collection
    BuildGeocodeTargetAreaRecords.call(broadcast.target_areas.geocode, locality_data:).map { it.merge(broadcast_id: broadcast.id) }
  end
end
