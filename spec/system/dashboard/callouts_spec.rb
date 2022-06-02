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
      expect(page).to have_link_to_action(
        :new, key: :callouts, href: new_dashboard_callout_path
      )
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

  it "can create a callout" do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    expect(page).to have_title("New Callout")

    fill_in("Audio URL", with: "https://www.example.com/sample.mp3")
    choose("Hello World")
    fill_in_key_value_for(:metadata, with: { key: "location:country", value: "kh" })
    fill_in_key_value_for(:settings, with: { key: "rapidpro:flow_id", value: "flow-id" })

    expect do
      click_action_button(:create, key: :submit, namespace: :helpers, model: "Callout")
    end.not_to have_enqueued_job(AudioFileProcessorJob)

    new_callout = Callout.last!
    expect(page).to have_current_path(dashboard_callout_path(new_callout))
    expect(page).to have_text("Callout was successfully created.")
    expect(new_callout.account).to eq(user.account)
    expect(new_callout.audio_file).not_to be_attached
    expect(new_callout.created_by).to eq(user)
    expect(new_callout.audio_url).to eq("https://www.example.com/sample.mp3")
    expect(new_callout.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    expect(new_callout.metadata).to eq("location" => { "country" => "kh" })
    expect(new_callout.settings).to eq("rapidpro" => { "flow_id" => "flow-id" })
  end

  it "can create a callout attaching an audio file" do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    attach_file("Audio file", Rails.root + file_fixture("test.mp3"))
    choose("Hello World")
    expect do
      click_action_button(:create, key: :submit, namespace: :helpers, model: "Callout")
    end.to have_enqueued_job(AudioFileProcessorJob)

    new_callout = Callout.last!
    expect(new_callout.audio_file).to be_attached
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
    click_action_button(:update, key: :submit, namespace: :helpers)

    expect(current_path).to eq(dashboard_callout_path(callout))
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

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(dashboard_callouts_path)
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
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_callout_path(callout)
      )
    end

    within("#related_links") do
      expect(page).to have_link_to_action(
        :index,
        key: :batch_operations,
        href: dashboard_callout_batch_operations_path(callout)
      )

      expect(page).to have_link_to_action(
        :index,
        key: :callout_participations,
        href: dashboard_callout_callout_participations_path(callout)
      )

      expect(page).to have_link_to_action(
        :index,
        key: :phone_calls,
        href: dashboard_callout_phone_calls_path(callout)
      )
    end

    within("#callout") do
      expect(page).to have_content(callout.id)
      expect(page).to have_link(callout.audio_url, href: callout.audio_url)
      expect(page).to have_link(callout.created_by_id.to_s, href: dashboard_user_path(callout.created_by))
      expect(page).to have_content("Status")
      expect(page).to have_content("Initialized")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Audio file")
      expect(page).to have_content("Audio URL")
      expect(page).to have_content("Call flow")
      expect(page).to have_content("Hello World")
      expect(page).to have_content("Metadata")
      expect(page).to have_content("location:country")
      expect(page).to have_content("Cambodia")
      expect(page).to have_content("Settings")
      expect(page).to have_content("rapidpro:flow_id")
      expect(page).to have_content("flow-id")
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

  it "can perform actions on callouts" do
    user = create(:user)
    callout = create(
      :callout,
      :initialized,
      account: user.account
    )

    sign_in(user)
    visit dashboard_callout_path(callout)

    click_action_button(:start_callout, key: :callouts, type: :link)

    expect(callout.reload).to be_running
    expect(page).to have_text("Event was successfully created.")
    expect(page).not_to have_link_to_action(:start_callout, key: :callouts)

    click_action_button(:stop_callout, key: :callouts, type: :link)

    expect(callout.reload).to be_stopped
    expect(page).not_to have_link_to_action(:stop_callout, key: :callouts)

    click_action_button(:resume_callout, key: :callouts, type: :link)

    expect(callout.reload).to be_running
    expect(page).not_to have_link_to_action(:resume_callout, key: :callouts)
    expect(page).to have_link_to_action(:stop_callout, key: :callouts)
  end
end
