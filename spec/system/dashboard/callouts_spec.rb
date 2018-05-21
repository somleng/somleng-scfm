require "rails_helper"

RSpec.describe "Callouts", :aggregate_failures do
  it "can list callouts" do
    user = create(:user)
    callout = create(:callout, :initialized, account: user.account)
    other_callout = create(:callout)

    sign_in(user)
    visit dashboard_callouts_path

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
      expect(page).to have_content("Status")
      expect(page).to have_content("Initialized")
      expect(page).to have_content(callout.province_name_en)
      expect(page).to have_content(callout.province_name_km)
    end
  end

  it "can create a callout", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.callouts.new"),
        href: new_dashboard_callout_path
      )
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_callout_information
    click_action_button(:create, key: :callouts)

    expect(page).to have_text("Callout was successfully created.")

    callout = Callout.first
    expect(callout.voice.attached?).to eq true
  end

  it "can update a callout", :js do
    user = create(:user)
    callout = create(:callout, account: user.account)

    sign_in(user)
    visit edit_dashboard_callout_path(callout)

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.callouts.edit"),
        href: edit_dashboard_callout_path(callout)
      )
    end

    expect(page).to have_link_to_action(:cancel)

    # wait for selectize default selected
    sleep 1
    fill_in_callout_information
    click_action_button(:update, key: :callouts)

    expect(page).to have_text("Callout was successfully updated.")
    expect(callout.voice.attached?).to eq true
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
    user = create(:admin)
    callout = create(
      :callout,
      :initialized,
      account: user.account
    )

    sign_in(user)
    visit dashboard_callout_path(callout)

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_callout_path(callout)
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
      expect(page).to have_content("Status")
      expect(page).to have_content("Initialized")
      expect(page).to have_content("Created at")
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

  def have_callout(callout)
    have_selector("#callout_#{callout.id}")
  end

  def fill_in_callout_information
    file_path = Rails.root + file_fixture("test.mp3")
    attach_file "Voice file", file_path
    select_selectize("#province", "Battambang")
    select_selectize("#communes", "Kantueu Pir")
  end
end
