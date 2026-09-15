require "rails_helper"

RSpec.resource "Notifications" do
  explanation <<~HEREDOC
    The **Notifications API** allows you to view and analyze the individual notifications that are sent to beneficiaries as part of a broadcast.

    A **Notification** represents a planned message to a single beneficiary, linked to a specific **Broadcast**. Each Notification may have one or more attempts, which track the actual transmission process.

    This API provides endpoints to:

    - **List notifications** associated with a specific broadcast.
    - **Retrieve statistics** for all notifications under a broadcast, such as:
      - Delivery success rate
      - Number of attempts
      - Time to delivery

    This API is ideal for implementers who need visibility into message distribution, system performance, and delivery outcomes at the individual recipient level.
  HEREDOC

  get "/v1/broadcasts/:broadcast_id/notifications" do
    FieldDefinitions::NotificationFields.each do |field|
      with_options scope: [ :filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    example "List all notifications for a broadcast" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      notifications = create_list(:notification, 3, broadcast:)
      _other_notification = create(:notification)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("notification")
      expect(json_response.fetch("data").pluck("id")).to match_array(notifications.map(&:id).map(&:to_s))
    end

    example "Filter notifications" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      notifications = create_list(:notification, 2, :succeeded, broadcast:)
      create(:notification, :succeeded, broadcast:, completed_at: 1.hour.ago, created_at: 1.hour.ago)
      create(:notification, :pending, broadcast:)
      create(:notification, broadcast: create(:broadcast, account:))

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, filter: { status: { eq: "succeeded" }, completed_at: { gt: 50.minutes.ago.utc.iso8601 } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("notification")
      expect(json_response.fetch("data").pluck("id")).to match_array(notifications.map(&:id).map(&:to_s))
    end

    example "List all notifications for a broadcast with beneficiary filters", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      male = create(:beneficiary, gender: "M")
      females = create_list(:beneficiary, 2, gender: "F")
      create(
        :beneficiary_address,
        beneficiary: females[0],
        iso_region_code: "KH-12",
      )
      create(
        :beneficiary_address,
        beneficiary: females[1],
        iso_region_code: "KH-1",
      )
      create(:notification, beneficiary: male, broadcast:)
      notification = create(:notification, beneficiary: females[0], broadcast:)
      create(:notification, beneficiary: females[1], broadcast:)

      set_authorization_header_for(account)
      do_request(
        broadcast_id: broadcast.id,
        filter: {
          "beneficiary.gender": { eq: "F" },
          "beneficiary.address.iso_region_code": { eq: "KH-12" }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("notification")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        notification.id.to_s
      )
    end

    example "List all notifications for a broadcast include their associations", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      create_list(:notification, 2, broadcast: broadcast)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, include: "beneficiary,broadcast")

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("notification")
      expect(json_response.fetch("included").pluck("type").uniq).to contain_exactly(
        "beneficiary", "broadcast"
      )
    end
  end

  get "/v1/broadcasts/:broadcast_id/notifications/:id" do
    example "Fetch an notification" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      notification = create(:notification, broadcast: broadcast)

      set_authorization_header_for(account)
      do_request(id: notification.id, broadcast_id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("notification")
      expect(json_response.dig("data", "id")).to eq(notification.id.to_s)
    end
  end

  get "/v1/broadcasts/:broadcast_id/notifications/stats" do
    with_options scope: :filter do
      FieldDefinitions::NotificationFields.each do |field|
        parameter(field.path, field.description, required: false, method: :_disabled)
      end
    end

    parameter(
      :group_by,
      "An array of fields to group by. Supported fields: #{V1::NotificationStatsRequestSchema::GROUPS.map { |group| "`#{group}`" }.join(", ")}.",
      required: true
    )

    example "Fetch notifications stats" do
      explanation <<~HEREDOC
        This endpoint provides statistical insights into the notifications under a broadcast managed within the OpenEWS system. This endpoint is particularly useful for generating reports, analyzing notification data, and monitoring the scope of your early warning system.

        ### Functionality

        This endpoint returns aggregated statistics about the notifications under a broadcast in your system. Common use cases include:

        - Counting the total number of notifications.
        - Grouping notifications by beneficiary's attributes such as location or gender.
        - Identifying trends or patterns in notification data.

        ### Parameters

        The endpoint may accept query parameters to filter or group the data. Common parameters include:

        - **Filters:** Specify conditions for narrowing down the results. For example, you might filter notifications by a specific status or beneficiary's fields.
        - **Group By:** Group the statistics by a particular attribute such as `status`, or beneficiary's fields.
      HEREDOC

      account = create(:account)
      broadcast = create(:broadcast, account:)
      male1_beneficiary = create(:beneficiary, account:, gender: "M")
      male2_beneficiary = create(:beneficiary, account:, gender: "M")
      male3_beneficiary = create(:beneficiary, account:, gender: "M")
      female1_beneficiary = create(:beneficiary, account:, gender: "F")
      female2_beneficiary = create(:beneficiary, account:, gender: "F")
      create(:notification, :succeeded, broadcast:, beneficiary: male1_beneficiary)
      create(:notification, :succeeded, broadcast:, beneficiary: male2_beneficiary)
      create(:notification, :failed, broadcast:, beneficiary: male3_beneficiary)
      create(:notification, :succeeded, broadcast:, beneficiary: female1_beneficiary)
      create(:notification, :succeeded, broadcast:, beneficiary: female2_beneficiary)

      set_authorization_header_for(account)
      do_request(
        broadcast_id: broadcast.id,
        filter: { "status" => { eq: "succeeded" } },
        group_by: [
          "beneficiary.gender"
        ]
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("stat", pagination: false)
      results = json_response.fetch("data").map { |data| data.dig("attributes", "result") }

      expect(results).to contain_exactly(
        {
          "beneficiary.gender" => "M",
          "value" => 2
        },
        {
          "beneficiary.gender" => "F",
          "value" => 2
        }
      )
    end
  end
end
