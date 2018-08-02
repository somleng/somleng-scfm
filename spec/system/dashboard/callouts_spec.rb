require "rails_helper"

RSpec.describe "Callouts", :aggregate_failures do
  it "can list callouts" do
    user = create(:user)
    sensor_event = create_sensor_event(account: user.account)
    callout = create(:callout, :initialized, sensor_event: sensor_event, account: user.account)
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
        callout.id,
        href: dashboard_callout_path(callout)
      )
      expect(page).to have_sortable_column("status")
      expect(page).to have_sortable_column("created_at")
      expect(page).not_to have_sortable_column("province")
      expect(page).not_to have_sortable_column("trigger_method")
      expect(page).to have_content("Trigger")
      expect(page).to have_content("Initialized")
      expect(page).to have_content("Sensor Event")
      expect(page).to have_content(callout.province_name_en)
      expect(page).to have_content(callout.province_name_km)
    end
  end

  it "can create a callout", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    expect(page).to have_title("Make Emergency Call")

    attach_file("Audio file", Rails.root + file_fixture("test.mp3"))
    select_commune

    expect do
      click_action_button(:create, key: :submit, namespace: :helpers, model: "Callout")
      expect(page).to have_text("Callout was successfully created.")
    end.to have_enqueued_job(AudioFileProcessorJob)

    new_callout = Callout.first
    expect(new_callout.audio_file).to be_attached
    expect(new_callout.call_flow_logic).to eq(CallFlowLogic::PlayMessage.to_s)
    callout_population = new_callout.callout_population
    expect(callout_population).to be_present
    expect(callout_population.contact_filter_params[:has_locations_in]).to eq(new_callout.commune_ids)
  end

  it "autoselects the user's province" do
    user = create(:user, province_ids: ["01"])

    sign_in(user)
    visit new_dashboard_callout_path

    expect(find_field("callout_province_id", visible: false)["data-default-value"]).to eq("01")
  end

  it "can update a callout", :js do
    user = create(:user)
    callout = create(:callout, account: user.account, commune_ids: ["010201"])
    _callout_population = create(:callout_population, callout: callout, account: callout.account)

    sign_in(user)
    visit edit_dashboard_callout_path(callout)

    expect(page).to have_title("Edit Callout")

    expect(page).to have_content("Banteay Neang")
    expect(page).to have_link_to_action(:cancel)

    select_commune
    click_action_button(:update, key: :submit, namespace: :helpers)

    expect(page).to have_text("Callout was successfully updated.")

    callout.reload
    expect(callout.callout_population.contact_filter_params[:has_locations_in]).to eq(callout.commune_ids)
  end

  it "can update a callout without an existing callout population", :js do
    user = create(:user)
    callout = create(:callout, account: user.account, commune_ids: ["010201"])

    sign_in(user)
    visit edit_dashboard_callout_path(callout)

    expect(page).to have_content("Banteay Neang")

    select_commune
    click_action_button(:update, key: :submit, namespace: :helpers)

    expect(page).to have_text("Callout was successfully updated.")

    callout.reload
    expect(callout.callout_population.contact_filter_params[:has_locations_in]).to eq(callout.commune_ids)
  end

  it "can show a callout" do
    user = create(:admin)
    sensor_event = create_sensor_event(account: user.account)
    callout = create(
      :callout,
      :initialized,
      account: user.account,
      sensor_event: sensor_event,
      call_flow_logic: CallFlowLogic::HelloWorld,
      audio_file: "test.mp3",
      audio_url: "https://example.com/audio.mp3"
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
      expect(page).to have_link(callout.sensor_event_id, href: dashboard_sensor_event_path(sensor_event))
      expect(page).to have_content("Status")
      expect(page).to have_content("Initialized")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Audio file")
      expect(page).to have_content("Audio url")
      expect(page).to have_content("Call flow")
      expect(page).to have_content("Hello World")
    end
  end

  it "can start a callout" do
    user = create(:user)
    callout = create(
      :callout,
      :initialized,
      account: user.account
    )

    callout_population = create(
      :callout_population,
      callout: callout
    )

    sign_in(user)
    visit dashboard_callout_path(callout)
    perform_enqueued_jobs do
      click_action_button(:start_callout, key: :callouts, type: :link)
    end

    expect(callout.reload).to be_running
    expect(callout_population.reload).to be_finished
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

  def select_commune
    select_selectize("#province", "Battambang")
    check("Kantueu Pir")
    expect(page).not_to have_content("Mongkol Borei")
  end
end
