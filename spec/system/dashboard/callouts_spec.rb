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
    end
  end

  it "can create a callout" do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_callout_path

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.callouts.new"))
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_key_value_for(:metadata, with: { key: "location:country", value: "kh" })
    click_action_button(:create, key: :callouts)

    new_callout = Callout.last!
    expect(current_path).to eq(dashboard_callout_path(new_callout))
    expect(page).to have_text("Callout was successfully created.")
    expect(new_callout.metadata).to eq("location" => { "country" => "kh" })
  end

  it "can update a callout", :js do
    user = create(:user)
    callout = create(
      :callout,
      account: user.account,
      metadata: { "location" => { "country" => "kh", "city" => "Phnom Penh" } }
    )

    sign_in(user)
    visit edit_dashboard_callout_path(callout)

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.callouts.edit"))
    end

    expect(page).to have_link_to_action(:cancel)

    remove_key_value_for(:metadata)
    remove_key_value_for(:metadata)
    click_action_button(:update, key: :callouts)

    expect(current_path).to eq(dashboard_callout_path(callout))
    expect(page).to have_text("Callout was successfully updated.")
    expect(callout.reload.metadata).to eq({})
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
      metadata: { "location" => { "country" => "Cambodia" } }
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
        key: :callout_populations,
        href: dashboard_callout_callout_populations_path(callout)
      )
    end

    within("#callout") do
      expect(page).to have_link(
        callout.id,
        href: dashboard_callout_path(callout)
      )

      expect(page).to have_content("Status")
      expect(page).to have_content("Initialized")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Metadata")
      expect(page).to have_content("location:country")
      expect(page).to have_content("Cambodia")
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
