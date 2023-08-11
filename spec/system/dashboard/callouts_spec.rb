require "rails_helper"

RSpec.describe "Callouts", :aggregate_failures do
  it "can list callouts" do
    user          = create(:user)
    callout       = create(
      :callout,
      :initialized,
      call_flow_logic: CallFlowLogic::HelloWorld,
      account: user.account
    )
    other_callout = create(:callout)

    sign_in(user)
    visit dashboard_callouts_path

    expect(page).to have_title("Callouts")

    within("#page_actions") do
      expect(page).to have_link("New", href: new_dashboard_callout_path)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(callout)
      expect(page).not_to have_content_tag_for(other_callout)
      expect(page).to have_content("#")
      expect(page).to have_link(
        callout.id.to_s,
        href: dashboard_callout_path(callout)
      )
      expect(page).to have_sortable_column("status")
      expect(page).to have_sortable_column("created_at")
      expect(page).to have_content("Initialized")
      expect(page).to have_sortable_column("call_flow_logic")
      expect(page).to have_content("Hello World")
    end
  end

  it "create and start a callout", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    expect(page).to have_title("New Callout")

    fill_in("Audio URL", with: "https://www.example.com/sample.mp3")
    choose("Hello World")

    fill_in_key_values_for(
      :metadata,
      with: {
        "location:country" => "kh"
      }
    )

    fill_in_key_values_for(
      :settings,
      with: {
        "rapidpro:flow_id" => "flow-id"
      }
    )

    expect { click_on("Create Callout") }.not_to have_enqueued_job(AudioFileProcessorJob)

    expect(page).to have_content("Callout was successfully created.")
    expect(page).to have_content(
      JSON.pretty_generate(
        "location" => { "country" => "kh" }
      )
    )
    expect(page).to have_content(
      JSON.pretty_generate(
        "rapidpro" => { "flow_id" => "flow-id" }
      )
    )
  end

  it "can create a callout attaching an audio file" do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    attach_file("Audio file", Rails.root + file_fixture("test.mp3"))
    choose("Hello World")
    expect { click_on("Create Callout") }.to have_enqueued_job(AudioFileProcessorJob)

    expect(page).to have_content("Callout was successfully created.")
  end

  it "can update a callout", :js do
    user = create(:user)
    callout = create(
      :callout,
      account: user.account,
      metadata: { "location" => { "country" => "kh", "city" => "Phnom Penh" } },
      settings: { "rapidpro" => { "flow_id" => "flow-id" } }
    )

    sign_in(user)
    visit edit_dashboard_callout_path(callout)

    expect(page).to have_title("Edit Callout")

    choose("Hello World")
    remove_key_value_for(:metadata)
    remove_key_value_for(:metadata)
    remove_key_value_for(:settings)
    click_on "Save"

    expect(page).to have_text("Callout was successfully updated.")
    expect(callout.reload.metadata).to eq({})
    expect(callout.reload.settings).to eq({})
    expect(callout.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
  end

  it "can delete a callout" do
    user = create(:user)
    callout = create(:callout, account: user.account)

    sign_in(user)
    visit dashboard_callout_path(callout)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_callouts_path, ignore_query: true)
    expect(page).to have_text("Callout was successfully destroyed.")
  end

  it "can show a callout" do
    user = create(:user)
    callout = create(
      :callout,
      :initialized,
      account: user.account,
      call_flow_logic: CallFlowLogic::HelloWorld,
      created_by: user,
      audio_file: file_fixture("test.mp3"),
      audio_url: "https://example.com/audio.mp3",
      metadata: { "location" => { "country" => "Cambodia" } },
      settings: { "rapidpro" => { "flow_id" => "flow-id" } }
    )

    sign_in(user)
    visit dashboard_callout_path(callout)

    expect(page).to have_title("Callout #{callout.id}")

    within("#page_actions") do
      expect(page).to have_link("Edit", href: edit_dashboard_callout_path(callout))
    end

    within("#related_links") do
      expect(page).to have_link(
        "Callout Populations",
        href: dashboard_callout_batch_operations_path(callout)
      )

      expect(page).to have_link(
        "Callout Participations",
        href: dashboard_callout_callout_participations_path(callout)
      )
      expect(page).to have_link(
        "Phone Calls",
        href: dashboard_callout_phone_calls_path(callout)
      )
    end

    within(".callout") do
      expect(page).to have_content(callout.id)
      expect(page).to have_link(callout.audio_url, href: callout.audio_url)
      expect(page).to have_link(
        callout.created_by_id.to_s,
        href: dashboard_user_path(callout.created_by)
      )
    end

    within("#callout_summary") do
      expect(page).to have_content("Callout Summary")
      expect(page).to have_link("Refresh", href: dashboard_callout_path(callout))
      expect(page).to have_content("Participants")
      expect(page).to have_content("Participants still to be called")
      expect(page).to have_content("Completed calls")
      expect(page).to have_content("Busy calls")
      expect(page).to have_content("Not answered calls")
      expect(page).to have_content("Failed calls")
      expect(page).to have_content("Errored calls")
    end
  end

  it "can perform actions on callouts", :js do
    user = create(:user)
    callout = create(
      :callout,
      :initialized,
      account: user.account
    )

    sign_in(user)
    visit dashboard_callout_path(callout)

    click_on("Start")

    expect(page).to have_content("Event was successfully created.")
    expect(page).not_to have_selector(:link_or_button, "Start")

    click_on("Stop")

    expect(page).not_to have_selector(:link_or_button, "Stop")

    click_on("Resume")

    expect(page).not_to have_selector(:link_or_button, "Resume")
    expect(page).to have_selector(:link_or_button, "Stop")
  end
end
