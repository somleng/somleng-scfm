require "rails_helper"

module V1
  RSpec.describe UpdateBroadcastRequestSchema, type: :request_schema do
    it "validates the audio_url" do
      broadcast = create(:broadcast, :pending, :voice_call)
      started_broadcast = create(:broadcast, :running, :voice_call)
      stopped_broadcast = create(:broadcast, :stopped, :voice_call)
      text_message_broadcast = create(:broadcast, :pending, :text_message)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "invalid-url" } } }, options: { resource: broadcast })
      ).not_to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "http://example.com/sample.mp3" } } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "http://example.com/sample.mp3" } } }, options: { resource: started_broadcast })
      ).not_to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "http://example.com/sample.mp3" } } }, options: { resource: stopped_broadcast })
      ).not_to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "http://example.com/sample.mp3" } } }, options: { resource: text_message_broadcast })
      ).not_to have_valid_field(:data, :attributes, :audio_url)
    end

    it "validates the message" do
      broadcast = create(:broadcast, :pending, :text_message)
      started_broadcast = create(:broadcast, :running, :text_message)
      stopped_broadcast = create(:broadcast, :stopped, :text_message)
      voice_broadcast = create(:broadcast, :pending, :voice_call)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :message)

      expect(
        validate_schema(input_params: { data: { attributes: { message: "Test message" } } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :message)

      expect(
        validate_schema(input_params: { data: { attributes: { message: "Test message" } } }, options: { resource: started_broadcast })
      ).not_to have_valid_field(:data, :attributes, :message)

      expect(
        validate_schema(input_params: { data: { attributes: { message: "Test message" } } }, options: { resource: stopped_broadcast })
      ).not_to have_valid_field(:data, :attributes, :message)

      expect(
        validate_schema(input_params: { data: { attributes: { message: "Test message" } } }, options: { resource: voice_broadcast })
      ).not_to have_valid_field(:data, :attributes, :message)
    end

    it "validates the beneficiary_filter" do
      broadcast = create(:broadcast, status: :pending)
      started_broadcast = create(:broadcast, :running)
      stopped_broadcast = create(:broadcast, :stopped)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(input_params: { data: { attributes: { beneficiary_filter: { status: { eq: "active" } } } } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(input_params: { data: { attributes: { beneficiary_filter: { status: { eq: "active" } } } } }, options: { resource: started_broadcast })
      ).not_to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(input_params: { data: { attributes: { beneficiary_filter: { status: { eq: "active" } } } } }, options: { resource: stopped_broadcast })
      ).not_to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channels: [ "audio" ],
                beneficiary_filter: {
                  gender: { eq: "F" }
                }
              }
            }
          },
          options: {
            resource: create(:broadcast, :pending, :audio)
          }
        )
      ).not_to have_valid_field(:data, :attributes, :beneficiary_filter)
    end

    it "validates the status" do
      account = create(:account)
      errored_broadcast = create(:broadcast, status: :errored, account:)
      pending_broadcast = create(:broadcast, status: :pending, account:)
      running_broadcast = create(:broadcast, status: :running, account:)
      stopped_broadcast = create(:broadcast, status: :stopped, account:)
      completed_broadcast = create(:broadcast, status: :completed, account:)
      queued_broadcast = create(:broadcast, status: :queued, account:)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "foobar" } } }, options: { resource: pending_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: pending_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "pending" } } }, options: { resource: running_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: running_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: stopped_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: completed_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: completed_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "queued" } } }, options: { resource: pending_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: errored_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: errored_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "queued" } } }, options: { resource: errored_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: queued_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice_call",
                status: "running"
              }
            }
          },
          options: {
            account:,
            resource: pending_broadcast
          }
        )
      ).not_to have_valid_schema(error_message: "Account not configured")
    end

    it "validates the beneficiary groups" do
      account = create(:account)
      broadcast = create(:broadcast, :pending, account:)
      audio_broadcast = create(:broadcast, :pending, :audio, account:)
      running_broadcast = create(:broadcast, :running, account:)
      beneficiary_group = create(:beneficiary_group, account:)
      other_beneficiary_group = create(:beneficiary_group)

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: 11.times.map { |index| { id: index + 1, type: "beneficiary_group" } }
                }
              }
            }
          },
          options: {
            account:,
            resource: broadcast
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data, error_message: "size cannot be greater than 10")

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: [
                    {
                      id: other_beneficiary_group.id,
                      type: "beneficiary_group"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: broadcast
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data)

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: [
                    {
                      id: beneficiary_group.id,
                      type: "beneficiary_group"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: running_broadcast
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data)

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: [
                    {
                      id: beneficiary_group.id,
                      type: "beneficiary_group"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: audio_broadcast
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data)
    end

    it "validates the target areas" do
      account = create(:account)
      broadcast = create(:broadcast, :pending, account:)
      running_broadcast = create(:broadcast, :running, account:)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                target_areas: {
                  geocode: [ {} ]
                }
              }
            }
          },
          options: {
            account:,
            resource: broadcast
          }
        )
      ).not_to have_valid_field(:data, :attributes, :target_areas, :geocode, 0, :iso_region_code)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                target_areas: {
                  geocode: [
                    { iso_region_code: "KH-1", administrative_division_level_3_code: "010201" }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: broadcast
          }
        )
      ).not_to have_valid_field(
        :data, :attributes, :target_areas, :geocode, 0,
        error_message: "must include contiguous administrative levels starting at level 1"
      )

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                target_areas: {
                  geocode: [
                    {
                      iso_region_code: "KH-1"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: running_broadcast
          }
        )
      ).not_to have_valid_field(:data, :attributes, :target_areas)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                target_areas: {
                  geocode: [
                    {
                      iso_region_code: "KH-1"
                    },
                    {
                      iso_region_code: "KH-2",
                      administrative_division_level_2_code: "0201"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: broadcast
          }
        )
      ).to have_valid_field(:data, :attributes, :target_areas, :geocode)
    end

    it "handles post processing" do
      account = create(:account)
      pending_broadcast = create(:broadcast, :pending, :voice_call, account:)
      errored_broadcast = create(:broadcast, :errored, :voice_call, account:)
      text_message_broadcast = create(:broadcast, :pending, :text_message, account:)

      result = validate_schema(
        input_params: {
          data: {
            id: pending_broadcast.id,
            attributes: {
              status: "running",
              audio_url: "http://example.com/sample.mp3"
            }
          }
        },
        options: { resource: pending_broadcast }
      ).output

      expect(result).to include(
        desired_status: :queued,
        audio_url: "http://example.com/sample.mp3",
      )

      result = validate_schema(
        input_params: {
          data: {
            id: errored_broadcast.id,
            attributes: {
              status: "running",
              audio_url: "http://example.com/sample.mp3"
            }
          }
        },
        options: { resource: errored_broadcast }
      ).output

      expect(result).to include(
        desired_status: :queued,
        audio_url: "http://example.com/sample.mp3"
      )

      result = validate_schema(
        input_params: {
          data: {
            id: text_message_broadcast.id,
            attributes: {
              status: "running",
              message: "Updated test message"
            }
          }
        },
        options: { resource: text_message_broadcast }
      ).output

      expect(result).to include(
        desired_status: :queued,
        message: "Updated test message"
      )
    end

    def validate_schema(input_params:, options: {})
      UpdateBroadcastRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
