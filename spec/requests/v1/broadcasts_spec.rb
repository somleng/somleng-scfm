require "rails_helper"

RSpec.resource "Broadcasts"  do
  get "/v1/broadcasts" do
    FieldDefinitions::BroadcastFields.each do |field|
      with_options scope: [ :filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    example "List all broadcasts" do
      account = create(:account)
      account_broadcast = create(:broadcast, account:)
      _other_account_broadcast = create(:broadcast)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        account_broadcast.id.to_s
      )
    end

    example "Filter broadcasts" do
      account = create(:account)
      matching_broadcast = create(
        :broadcast,
        :running,
        :text_message,
        account:,
        name: "Test Broadcast"
      )

      create(:broadcast, :running, account:, started_at: 6.hours.ago, created_at: 6.hours.ago)
      create(:broadcast, :stopped, account:)

      set_authorization_header_for(account)
      do_request(
        filter: {
          status: { eq: "running" },
          started_at: { gt: 5.hours.ago.utc.iso8601 },
          name: { starts_with: "Test" },
          channels: { contains: "text_message" }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        matching_broadcast.id.to_s
      )
    end

    example "Filter running broadcasts by included coverage area" do
      explanation <<~HEREDOC
        Use the `contains` operator to return broadcasts where any target area contains any of specified administrative divisions.
        The filter matches broadcasts whose target area coverage contains the provided geocodes.
      HEREDOC

      account = create(:account)
      matching_broadcast = create(:broadcast, :running, account:)
      create(:broadcast, :running, account:)
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102", "010201" ]
      )

      set_authorization_header_for(account)
      do_request(
        filter: {
          status: {
            eq: :running
          },
          "target_areas.geocode.administrative_division_level_3_code": {
            contains: [ "010201",  "010202" ]
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        matching_broadcast.id.to_s
      )
    end

    example "Filter running broadcasts by exclusive coverage area" do
      explanation <<~HEREDOC
        Use the `eq` operator to return broadcasts where all target areas match exactly the specified administrative divisions.
        The filter matches broadcasts whose target areas are entirely within the provided geocodes.
      HEREDOC

      account = create(:account)
      matching_broadcast = create(:broadcast, :running, account:)
      non_matching_broadcast = create(:broadcast, :running, account:)
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102", "010201" ]
      )
      create(
        :geocode_target_area,
        broadcast: non_matching_broadcast,
        path: [ "KH-2" ]
      )

      set_authorization_header_for(account)
      do_request(
        filter: {
          status: {
            eq: :running
          },
          "target_areas.geocode.iso_region_code": {
            eq: [ "KH-1" ]
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        matching_broadcast.id.to_s
      )
    end
  end

  get "/v1/broadcasts/:id" do
    example "Fetch a broadcast" do
      account = create(:account)
      broadcast = create(:broadcast, account:)

      set_authorization_header_for(account)
      do_request(id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "id")).to eq(broadcast.id.to_s)
    end

    example "Fetch a broadcast with read:broadcast scope", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)

      access_token = create(:access_token, account:, scopes: :"read:broadcast")
      set_authorization_header(access_token:)
      do_request(id: broadcast.id)

      expect(response_status).to eq(200)
    end
  end

  post "/v1/broadcasts" do
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `broadcast`",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :channels,
        "An array of delivery channels for the broadcast. At least one channel is required. Currently, the array must contain exactly one channel, although support for multiple channels may be added in future releases. Supported values are #{Broadcast.channel.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: true,
        method: :_disabled
      )

      parameter(
        :message,
        "The text content of the broadcast. This field is required if any of the selected channels require text content.",
        method: :_disabled
      )

      parameter(
        :audio_url,
        "A publicly accessible URL pointing to the audio message to be delivered. This field is required if any of the selected channels require audio content.",
        method: :_disabled
      )

      parameter(
        :status,
        "If supplied, the value must be `running`. The broadcast will be created and started immediately. If omitted, the broadcast will be created in a pending state.",
        method: :_disabled
      )

      parameter(
        :metadata,
        "A set of key-value pairs that can be attached to the broadcast. This can be useful for storing additional structured information associated with the broadcast.",
        method: :_disabled
      )
    end

    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :data, :attributes, :beneficiary_filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    with_options scope: [ :data, :relationships, :beneficiary_groups ] do
      parameter(
        :"data.*.type", "Must be `beneficiary_group`",
        required: false,
        method: :_disabled
      )
      parameter(
        :"data.*.id", "The unique ID of the beneficiary group",
        required: false,
        method: :_disabled
      )
    end

    example "Create and start a voice call broadcast" do
      explanation <<~HEREDOC
        For broadcasts with *deliverable notifications*, such as voice calls or text messages,
        `beneficiary_filter` defines which *beneficiaries* are eligible to receive the broadcast,
        while `target_areas` further filters those beneficiaries based on their geographic location.
        Multiple geographic targets can be specified in `target_areas`.
        A geographic target can include one or more geographic codes, allowing you to target a region as a whole or a specific administrative area within a region.
        Geographic targets are combined using `OR` logic, so a beneficiary must match the `beneficiary_filter` and be located within any of the specified geographic targets.
      HEREDOC

      account = create(:account, :configured_for_broadcasts)
      oauth_application = create(:oauth_application, owner: account)
      webhook_endpoint = create(:webhook_endpoint, oauth_application:, subscriptions: [ "broadcast.created", "broadcast.updated" ])
      stub_request(:post, webhook_endpoint.url).to_return(status: 200)

      create(:beneficiary_address, beneficiary: create(:beneficiary, gender: "M", account:), iso_region_code: "KH-1")
      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          data: {
            type: :broadcast,
            attributes: {
              channels: [ "voice_call" ],
              audio_url: "https://www.example.com/test.mp3",
              status: :running,
              beneficiary_filter: {
                gender: { eq: "M" }
              },
              target_areas: {
                geocode: [
                  { iso_region_code: "KH-1" },
                  {
                    iso_region_code: "KH-2",
                    administrative_division_level_2_code: "0201"
                  }
                ]
              }
            }
          }
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "channels" => [ "voice_call" ],
        "status" => "queued",
        "audio_url" => "https://www.example.com/test.mp3",
        "beneficiary_filter" => {
          "gender" => { "eq" => "M" }
        },
        "target_areas" => {
          "geocode" => [
            { "iso_region_code" => "KH-1" },
            {
              "iso_region_code" => "KH-2",
              "administrative_division_level_2_code" => "0201"
            }
          ]
        }
      )

      expect(webhook_endpoint.webhook_request_logs).to contain_exactly(
        have_attributes(
          event: have_attributes(
            type: "broadcast.created"
          )
        ),
        have_attributes(
          event: have_attributes(
            type: "broadcast.updated"
          )
        )
      )
    end

    example "Create and start a text message broadcast" do
      account = create(:account, :configured_for_broadcasts)
      create(
        :beneficiary_address,
        beneficiary: create(:beneficiary, gender: "M", account:),
        iso_region_code: "KH-1"
      )

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          data: {
            type: :broadcast,
            attributes: {
              channels: [ "text_message" ],
              message: "Test message",
              status: :running,
              beneficiary_filter: {
                gender: { eq: "M" }
              },
              target_areas: {
                geocode: [
                  { iso_region_code: "KH-1" }
                ]
              }
            }
          }
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "channels" => [ "text_message" ],
        "status" => "queued",
        "message" => "Test message",
        "beneficiary_filter" => {
          "gender" => { "eq" => "M" }
        },
        "target_areas" => {
          "geocode" => [
            { "iso_region_code" => "KH-1" }
          ]
        }
      )
    end

    example "Create and start an audio broadcast" do
      explanation <<~HEREDOC
        For broadcasts *without deliverable notifications*,
        such as audio broadcasts, `beneficiary_filter` cannot be specified.
        Multiple geographic targets can be specified in `target_areas` to define the geographic areas where the broadcast should be delivered.
        Each geographic target can include one or more geographic codes,
        allowing you to target a region as a whole or a specific administrative area within a region.
        In this case, `target_areas` does not filter beneficiaries; it only determines the geographic areas targeted by the broadcast.
      HEREDOC

      account = create(:account)
      set_authorization_header_for(account)
      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      perform_enqueued_jobs do
        do_request(
          data: {
            type: :broadcast,
            attributes: {
              channels: [ "audio" ],
              audio_url: "https://www.example.com/test.mp3",
              status: :running,
              target_areas: {
                geocode: [
                  {
                    iso_region_code: "KH-1",
                    administrative_division_level_2_code: "1201",
                    administrative_division_level_3_code: "120101"
                  }
                ]
              }
            }
          }
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "channels" => [ "audio" ],
        "status" => "queued",
        "target_areas" => {
          "geocode" => [
            {
              "iso_region_code" => "KH-1",
              "administrative_division_level_2_code" => "1201",
              "administrative_division_level_3_code" => "120101"
            }
          ]
        }
      )
    end

    example "Create broadcast with a beneficiary group" do
      explanation <<~HEREDOC
        When creating a broadcast, you can target one or more beneficiary groups **in addition to** *or* **instead of** using a beneficiary filter.
        Beneficiaries included through groups will receive notifications with higher priority than those matched solely by the filter.
        This is especially useful when you need to ensure that specific groups, such as response teams, receive notifications regardless of filter criteria.
      HEREDOC

      account = create(:account)
      beneficiary_group = create(:beneficiary_group, account:)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :broadcast,
          attributes: {
            channels: [ "voice_call" ],
            audio_url: "https://www.example.com/test.mp3"
          },
          relationships: {
            beneficiary_groups: {
              data: [
                { type: "beneficiary_group", id: beneficiary_group.id }
              ]
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
    end

    example "Create broadcast for specific beneficiaries" do
      explanation <<~HEREDOC
        You can create a broadcast for a specific set of beneficiaries using the phone number filter. This is especially useful when you want to quickly send a message to a known group—such as staff, partners, or a predefined list—without needing to assign them to a beneficiary group.
        It's also helpful for **testing** broadcasts in a live environment without affecting the full beneficiary population. The priority remains the same as standard broadcasts, ensuring consistent behavior while giving you more control over delivery.
      HEREDOC

      account = create(:account, :configured_for_broadcasts)
      beneficiaries = create_list(:beneficiary, 2, account:)
      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          data: {
            type: :broadcast,
            attributes: {
              channels: [ "voice_call" ],
              audio_url: "https://www.example.com/test.mp3",
              status: :running,
              beneficiary_filter: {
                phone_number: { in: beneficiaries.pluck(:phone_number) }
              }
            }
          }
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
    end

    example "Supports beneficiary address filters", document: false do
      account = create(:account, :configured_for_broadcasts)
      beneficiary = create(:beneficiary, account:)
      create(:beneficiary, account:)
      create(:beneficiary_address, beneficiary:, iso_region_code: "KH-1")

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          data: {
            type: :broadcast,
            attributes: {
              channels: [ "text_message" ],
              message: "Test message",
              status: :running,
              beneficiary_filter: {
                "address.iso_region_code" => { eq: "KH-1" }
              }
            }
          }
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "status" => "queued",
        "beneficiary_filter" => {
          "address.iso_region_code" => { "eq" => "KH-1" }
        }
      )
      broadcast = Broadcast.find(json_response.dig("data", "id"))
      expect(broadcast.beneficiaries).to contain_exactly(beneficiary)
    end

    example "Fail to create a broadcast", document: false do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :broadcast,
          attributes: {
            channels: [ "voice_call" ],
            audio_url: nil,
            beneficiary_filter: {}
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/data/attributes/beneficiary_filter")
      expect(json_response.dig("errors", 1, "source", "pointer")).to eq("/data/attributes/audio_url")
    end

    example "Fail to create a broadcast without write scope", document: false do
      account = create(:account)

      access_token = create(:access_token, account:, scopes: :"read:broadcast")
      set_authorization_header(access_token:)
      do_request

      expect(response_status).to eq(403)
    end
  end

  patch "/v1/broadcasts/:id" do
    with_options scope: %i[data] do
      parameter(
        :id,
        "The unique identifier of the broadcast to update.",
        required: true
      )

      parameter(
        :type,
        "The resource type. Must be `broadcast`.",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :message,
        "The text content of the broadcast. This field can only be updated before the broadcast has started.",
        method: :_disabled
      )

      parameter(
        :audio_url,
        "A publicly accessible URL pointing to the audio message to be delivered. This field can only be updated before the broadcast has started.",
        method: :_disabled
      )

      parameter(
        :status,
        "Updates the lifecycle state of the broadcast. Supported values are #{V1::UpdateBroadcastRequestSchema::VALID_STATES.map { "`#{it}`" }.join(", ")}.",
        method: :_disabled
      )

      parameter(
        :metadata,
        "A set of key-value pairs that can be attached to the broadcast. This can be useful for storing additional structured information associated with the broadcast.",
        method: :_disabled
      )
    end

    with_options scope: [ :data, :relationships, :beneficiary_groups ] do
      parameter(
        :"data.*.type", "Must be `beneficiary_group`",
        required: false,
        method: :_disabled
      )
      parameter(
        :"data.*.id", "The unique ID of the beneficiary group",
        required: false,
        method: :_disabled
      )
    end

    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :data, :attributes, :beneficiary_filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    example "Start a broadcast" do
      account = create(:account, :configured_for_broadcasts)
      beneficiary = create(:beneficiary, account:, gender: "F")
      create(:beneficiary, account:, gender: "M")
      broadcast = create(
        :broadcast,
        status: :pending,
        account:,
        audio_url: "https://www.example.com/test.mp3",
        beneficiary_filter: {
          gender: {
            eq: "F"
          }
        }
      )
      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          id: broadcast.id,
          data: {
            id: broadcast.id,
            type: :broadcast,
            attributes: {
              status: "running"
            }
          }
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(broadcast.reload.status).to eq("running")
      expect(broadcast.audio_file).to be_attached
      expect(broadcast.beneficiaries).to contain_exactly(beneficiary)
      expect(broadcast.delivery_attempts.count).to eq(1)
      expect(broadcast.delivery_attempts.first.beneficiary).to eq(beneficiary)
    end

    example "Stop a broadcast" do
      account = create(:account)
      broadcast = create(
        :broadcast,
        :running,
        :with_attached_audio,
        account:
      )

      set_authorization_header_for(account)
      do_request(
        id: broadcast.id,
        data: {
          id: broadcast.id,
          type: :broadcast,
          attributes: {
            status: "stopped"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "status" => "stopped"
      )
    end

    example "Fail to start a broadcast", document: false do
      account = create(:account, :configured_for_broadcasts)
      broadcast = create(
        :broadcast,
        :with_attached_audio,
        status: :pending,
        account:,
      )

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          id: broadcast.id,
          data: {
            id: broadcast.id,
            type: :broadcast,
            attributes: {
              status: "running"
            }
          }
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(broadcast.reload).to have_attributes(
        status: "errored",
        error_code: "no_matching_beneficiaries"
      )
    end

    example "Update a broadcast" do
      account = create(:account)
      beneficiary_group = create(:beneficiary_group, account:)
      broadcast = create(
        :broadcast,
        status: :pending,
        account:,
        audio_url: "https://www.example.com/old.mp3",
        beneficiary_filter: {
          gender: {
            eq: "M"
          }
        }
      )
      create(:broadcast_beneficiary_group, beneficiary_group:, broadcast:)

      set_authorization_header_for(account)
      do_request(
        id: broadcast.id,
        data: {
          id: broadcast.id,
          type: :broadcast,
          attributes: {
            audio_url: "https://www.example.com/new.mp3",
            beneficiary_filter: {
              gender: { eq: "F" }
            },
            target_areas: {
              geocode: [
                { iso_region_code: "KH-1" }
              ]
            }
          },
          relationships: {
            beneficiary_groups: {
              data: [
                { type: "beneficiary_group", id: beneficiary_group.id }
              ]
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data")).to include(
        "attributes" => include(
          "status" => "pending",
          "audio_url" => "https://www.example.com/new.mp3",
          "beneficiary_filter" => {
            "gender" => { "eq" => "F" }
          },
          "target_areas" => {
            "geocode" => [
              { "iso_region_code" => "KH-1" }
            ]
          }
        ),
        "relationships" => {
          "beneficiary_groups" => {
            "data" => [
              { "type" => "beneficiary_group", "id" => beneficiary_group.id.to_s }
            ]
          }
        }
      )
    end

    example "Fail to update a broadcast", document: false do
      account = create(:account)
      broadcast = create(
        :broadcast,
        account:,
        status: :running
      )

      set_authorization_header_for(account)
      do_request(
        id: broadcast.id,
        data: {
          id: broadcast.id,
          type: :broadcast,
          attributes: {
            status: "pending"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/data/attributes/status")
    end
  end

  get "/v1/broadcasts/:broadcast_id/audio_file" do
    example "Download a broadcast's audio file" do
      account = create(:account)
      broadcast = create(:broadcast, :with_attached_audio, audio_filename: "test.mp3", account:)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to end_with(".mp3")
    end

    example "Handle when broadcast's audio file is not available", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:, audio_file: nil)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(406)
    end
  end
end
