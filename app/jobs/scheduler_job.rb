class SchedulerJob < ApplicationJob
  def perform
    accounts.find_each do |account|
      queue_batch_operation!(account, type: BatchOperation::PhoneCallCreate)
      queue_batch_operation!(account, type: BatchOperation::PhoneCallQueue)
      queue_batch_operation!(account, type: BatchOperation::PhoneCallQueueRemoteFetch)
    end
  end

  private

  def accounts
    Account.joins(:access_tokens).merge(AccessToken.with_permissions(:batch_operations_write))
  end

  def queue_batch_operation!(account, type:)
    client = client_for(account)
    response = client.post(url_helpers.api_batch_operations_path, type: type)
    return unless response.success?

    batch_operation_id = JSON.parse(response.body).fetch("id")
    client.post(
      url_helpers.api_batch_operation_batch_operation_events_path(batch_operation_id),
      event: :queue
    )
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def client_for(account)
    Faraday.new(url: url_helpers.root_url) do |conn|
      conn.request :url_encoded
      conn.basic_auth(account.write_batch_operation_access_token.token, nil)
      conn.adapter Faraday.default_adapter
    end
  end
end
