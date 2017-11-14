class BatchOperation::Base < ApplicationRecord
  self.table_name = :batch_operations

  include CustomStoreReaders
  include MetadataHelpers
  include Wisper::Publisher

  conditionally_serialize(:parameters, JSON)
  conditionally_store(:parameters, :coder => JSON)

  validates :type, :presence => true

  include AASM

  aasm :column => :status do
    state :preview, :initial => true
    state :queued
    state :running
    state :finished

    event :queue, :after_commit => :publish_queued do
      transitions(
        :from => :preview,
        :to => :queued
      )
    end

    event :start do
      transitions(
        :from => :queued,
        :to => :running
      )
    end

    event :finish do
      transitions(
        :from => :running,
        :to => :finished
      )
    end

    event :requeue, :after_commit => :publish_queued do
      transitions(
        :from => :finished,
        :to => :queued
      )
    end
  end

  private

  def publish_queued
    broadcast(:batch_operation_queued, self)
  end
end
