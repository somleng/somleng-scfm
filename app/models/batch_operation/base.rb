module BatchOperation
  class Base < ApplicationRecord
    include CustomRoutesHelper["batch_operations"]
    include AASM

    PERMITTED_API_TYPES = [
      "BatchOperation::CalloutPopulation"
    ].freeze

    self.table_name = :batch_operations

    include CustomStoreReaders
    include MetadataHelpers
    include Wisper::Publisher

    belongs_to :account

    validates :type, presence: true
    validates :parameters, json: true

    before_validation :set_default_parameters, on: :create

    def self.from_type_param(type)
      PERMITTED_API_TYPES.include?(type) ? type.constantize : where(type: PERMITTED_API_TYPES)
    end

    aasm column: :status, skip_validation_on_save: true do
      state :preview, initial: true
      state :queued
      state :running
      state :finished

      event :queue, after_commit: :publish_queued do
        transitions(
          from: :preview,
          to: :queued
        )
      end

      event :start do
        transitions(
          from: :queued,
          to: :running
        )
      end

      event :finish do
        transitions(
          from: :running,
          to: :finished
        )
      end

      event :requeue, after_commit: :publish_queued do
        transitions(
          from: :finished,
          to: :queued
        )
      end
    end

    def serializable_hash(options = nil)
      options ||= {}
      super(
        {
          methods: :type
        }.merge(options)
      )
    end

    private

    def publish_queued
      broadcast(:batch_operation_queued, self)
    end

    def set_default_parameters
      return if account.blank?

      default_parameters = account.settings.fetch(batch_operation_account_settings_param, {})
      self.parameters = default_parameters.deep_merge(parameters)
    end

    def batch_operation_account_settings_param; end
  end
end
