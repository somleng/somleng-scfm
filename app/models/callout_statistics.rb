class CalloutStatistics
  include ActiveModel::Serializers::JSON

  attr_accessor :callout

  delegate :status,
           :participations,
           :to => :callout, :prefix => true

  delegate :callout_participations,
           :calls,
           :to => :callout

  delegate :count,
           :remaining,
           :completed,
           :to => :callout_participations,
           :prefix => true

  delegate :completed,
           :created,
           :scheduling,
           :fetching_status,
           :waiting_for_completion,
           :queued,
           :in_progress,
           :errored,
           :failed,
           :busy,
           :not_answered,
           :canceled,
           :to => :calls,
           :prefix => true

  delegate :count, :to => :calls_completed, :prefix => true
  delegate :count, :to => :calls_created, :prefix => true
  delegate :count, :to => :calls_scheduling, :prefix => true
  delegate :count, :to => :calls_fetching_status, :prefix => true
  delegate :count, :to => :calls_waiting_for_completion, :prefix => true
  delegate :count, :to => :calls_queued, :prefix => true
  delegate :count, :to => :calls_in_progress, :prefix => true
  delegate :count, :to => :calls_errored, :prefix => true
  delegate :count, :to => :calls_failed, :prefix => true
  delegate :count, :to => :calls_busy, :prefix => true
  delegate :count, :to => :calls_not_answered, :prefix => true
  delegate :count, :to => :calls_canceled, :prefix => true

  delegate :count, :to => :callout_participations_remaining, :prefix => true
  delegate :count, :to => :callout_participations_completed, :prefix => true


  def initialize(options = {})
    self.callout = options[:callout]
  end

  def attributes
    {
      :callout_status => nil,
      :callout_participations => nil,
      :callout_participations_remaining => nil,
      :callout_participations_completed => nil,
      :calls_completed => nil,
      :calls_initialized => nil,
      :calls_scheduling => nil,
      :calls_fetching_status => nil,
      :calls_waiting_for_completion => nil,
      :calls_queued => nil,
      :calls_in_progress => nil,
      :calls_errored => nil,
      :calls_failed => nil,
      :calls_busy => nil,
      :calls_not_answered => nil,
      :calls_canceled => nil
    }
  end

  private

  def read_attribute_for_serialization(key)
    method_to_serialize = attributes_for_serialization[key]
    method_to_serialize && public_send(method_to_serialize) || super
  end

  def attributes_for_serialization
    @attributes_for_serialization ||= {
      :callout_participations => :callout_participations_count,
      :callout_participations_remaining => :callout_participations_remaining_count,
      :callout_participations_completed => :callout_participations_completed_count,
      :calls_completed => :calls_completed_count,
      :calls_initialized => :calls_created_count,
      :calls_scheduling => :calls_scheduling_count,
      :calls_fetching_status => :calls_fetching_status_count,
      :calls_waiting_for_completion => :calls_waiting_for_completion_count,
      :calls_queued => :calls_queued_count,
      :calls_in_progress => :calls_in_progress_count,
      :calls_errored => :calls_errored_count,
      :calls_failed => :calls_failed_count,
      :calls_busy => :calls_busy_count,
      :calls_not_answered => :calls_not_answered_count,
      :calls_canceled => :calls_canceled_count
    }
  end
end
