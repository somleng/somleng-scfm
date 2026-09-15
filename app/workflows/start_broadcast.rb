class StartBroadcast < ApplicationWorkflow
  attr_reader :broadcast, :broadcast_preview

  class Error < Errors::ApplicationError; end

  delegate :account, to: :broadcast, private: true
  delegate :filtered_beneficiaries, :group_beneficiaries, to: :broadcast_preview, private: true

  def initialize(broadcast, **options)
    super()
    @broadcast = broadcast
    @broadcast_preview = options.fetch(:broadcast_preview) { BroadcastPreview.new(broadcast) }
  end

  def call
    return unless broadcast.queued?

    prepare_audio_file if broadcast.channel_capabilities.any?(&:audio?)

    ApplicationRecord.transaction do
      if broadcast.channel_capabilities.any?(&:deliverable?)
        create_notifications
        create_delivery_attempts
      end

      broadcast.error_code = nil
      broadcast.transition_to!(:running, touch: :started_at)
    end
  rescue DownloadBroadcastAudioFile::Error, Error => e
    broadcast.mark_as_errored!(e.code)
  ensure
    CreateEvent.call(type: "broadcast.updated", resource: broadcast)
  end

  private

  def prepare_audio_file
    DownloadBroadcastAudioFile.call(broadcast) unless broadcast.audio_file.attached?
    blob = broadcast.audio_file.blob
    CopyBlobWithExtension.call(blob, bucket: blob.service.bucket.name) if storage_service?(blob, :amazon)
  end

  def storage_service?(blob, service_name)
    raise(ArgumentError, "Unknown storage service name: #{service_name}") unless Rails.application.config.active_storage.service_configurations.key?(service_name.to_s)
    blob.service.name.to_sym == service_name.to_sym
  end

  def create_notifications
    raise(Error.new(code: :account_not_configured_for_channel)) unless broadcast.account.configured_for_broadcasts?
    notifications = []

    group_beneficiaries.find_each do |beneficiary|
      notifications << build_notification(beneficiary, priority: 0)
    end

    filtered_beneficiaries.find_each do |beneficiary|
      notifications << build_notification(beneficiary, priority: 1)
    end

    raise(Error.new(code: :no_matching_beneficiaries)) if notifications.none?

    Notification.upsert_all(notifications)
  end

  def create_delivery_attempts
    delivery_attempts = broadcast.notifications.find_each.map do |notification|
      {
        broadcast_id: broadcast.id,
        beneficiary_id: notification.beneficiary_id,
        notification_id: notification.id,
        phone_number: notification.phone_number,
        status: :created
      }
    end

    DeliveryAttempt.upsert_all(delivery_attempts)
  end

  def build_notification(beneficiary, **params)
    {
      broadcast_id: broadcast.id,
      beneficiary_id: beneficiary.id,
      phone_number: beneficiary.phone_number,
      delivery_attempts_count: 1,
      status: :pending,
      **params
    }
  end
end
