require "rails_helper"

RSpec.describe "Callouts", :aggregate_failures do
  it "can list callouts" do
    user          = create(:user)
    callout       = create(:callout, :initialized, account: user.account)
    other_callout = create(:callout)

    sign_in(user)
    visit dashboard_callouts_path

    expect(page).to have_title("Callouts")

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :new, key: :callouts, href: new_dashboard_callout_path
      )
      expect(page).to have_link_to_action(:index, key: :callouts)
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
      expect(page).to have_content("Initialized")
      expect(page).to have_content(callout.province_name_en)
      expect(page).to have_content(callout.province_name_km)
    end
  end

  it "can create a callout", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    expect(page).to have_title("Make Emergency Call")

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.callouts.new"),
        href: new_dashboard_callout_path
      )
    end

    expect(page).to have_link_to_action(:cancel)

    attach_file("Audio file", Rails.root + file_fixture("test.mp3"))
    select_commune

    expect do
      click_action_button(:create, key: :submit, namespace: :helpers, model: "Callout")
      expect(page).to have_text("Callout was successfully created.")
    end.to have_enqueued_job(AudioFileProcessorJob)

    new_callout = Callout.first
    expect(new_callout.audio_file).to be_attached
    expect(new_callout.call_flow_logic).to eq(CallFlowLogic::PlayMessage.to_s)
    expect(new_callout.callout_population).to be_present
    expect(new_callout.callout_population.contact_filter_metadata[:commune_id]).to eq(new_callout.commune_ids)
  end

  it "can update a callout", :js do
    user = create(:user)
    callout = create(:callout, account: user.account, commune_ids: ["010201"])
    _callout_population = create(:callout_population, callout: callout, account: callout.account)

    sign_in(user)
    visit edit_dashboard_callout_path(callout)

    expect(page).to have_title("Edit Callout")

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.callouts.edit"),
        href: edit_dashboard_callout_path(callout)
      )
    end

    expect(page).to have_content("Banteay Neang")
    expect(page).to have_link_to_action(:cancel)

    select_commune
    click_action_button(:update, key: :submit, namespace: :helpers)

    expect(page).to have_text("Callout was successfully updated.")

    callout.reload
    expect(callout.callout_population.contact_filter_metadata[:commune_id]).to eq(callout.commune_ids)
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
    expect(callout.callout_population.contact_filter_metadata[:commune_id]).to eq(callout.commune_ids)
  end

  it "can show a callout" do
    user = create(:admin)
    callout = create(
      :callout,
      :initialized,
      account: user.account,
      call_flow_logic: CallFlowLogic::HelloWorld,
      audio_file: "test.mp3",
      audio_url: "https://example.com/audio.mp3"
    )
    callout_population = create(:callout_population, callout: callout, account: callout.account)


    sign_in(user)
    visit dashboard_callout_path(callout)

    expect(page).to have_title("Callout #{callout.id}")

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_callout_path(callout)
      )

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

      expect(page).to have_link_to_action(
        :preview,
        href: dashboard_batch_operation_preview_contacts_path(callout_population)
      )
    end

    within("#callout") do
      expect(page).to have_content(callout.id)
      expect(page).to have_link(callout.audio_url, href: callout.audio_url)
      expect(page).to have_content("Status")
      expect(page).to have_content("Initialized")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Audio file")
      expect(page).to have_content("Audio url")
      expect(page).to have_content("Call flow")
      expect(page).to have_content("Hello World")
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

  def select_commune
    select_selectize("#province", "Battambang")
    select_selectize("#communes", "Kantueu Pir")
  end
end
