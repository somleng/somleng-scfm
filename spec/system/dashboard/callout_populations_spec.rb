require "rails_helper"

RSpec.describe "Callout Populations" do
  it "can list all the callout populations" do
    user = create(:user)
    callout = create(:callout, account: user.account)
    callout_population = create(
      :callout_population, :preview,
      callout: callout, account: user.account
    )
    other_callout_population = create(:callout_population, account: user.account)

    sign_in(user)
    visit(dashboard_callout_callout_populations_path(callout))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :new, key: :callout_populations, href: new_dashboard_callout_callout_population_path(callout)
      )
      expect(page).to have_link_to_action(:index, key: :callout_populations)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(callout_population)
      expect(page).not_to have_content_tag_for(other_callout_population)
      expect(page).to have_content("#")
      expect(page).to have_link(
        callout_population.id,
        href: dashboard_callout_callout_population_path(callout, callout_population)
      )
      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
    end
  end

  it "can create a callout population", :js do
    user = create(:user)
    callout = create(:callout, account: user.account)

    sign_in(user)
    visit(new_dashboard_callout_callout_population_path(callout))

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.callout_populations.new"))
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_key_value_for(:contact_filter_metadata, with: { key: "gender", value: "f" }, index: 0)
    add_key_value_for(:contact_filter_metadata)
    fill_in_key_value_for(:contact_filter_metadata, with: { key: "location:country", value: "kh" }, index: 1)
    click_action_button(:create, key: :callout_populations)

    new_callout_population = callout.reload.callout_populations.last!
    expect(current_path).to eq(dashboard_callout_callout_population_path(callout, new_callout_population))
    expect(page).to have_text("Callout population was successfully created.")
    asserted_contact_filter_metadata = { "gender" => "f", "location" => { "country" => "kh" } }
    expect(new_callout_population.contact_filter_metadata).to eq(asserted_contact_filter_metadata)
  end

  it "can update a callout population", :js do
    user = create(:user)
    callout = create(:callout, account: user.account)

    callout_population = create(
      :callout_population,
      contact_filter_metadata: {
        "gender" => "f",
        "location" => {
          "country_code" => "kh"
        }
      },
      callout: callout,
      account: user.account
    )

    sign_in(user)
    visit(
      edit_dashboard_callout_callout_population_path(
        callout, callout_population
      )
    )

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.callout_populations.edit"))
    end

    expect(page).to have_link_to_action(:cancel)

    remove_key_value_for(:contact_filter_metadata)
    remove_key_value_for(:contact_filter_metadata)
    add_key_value_for(:contact_filter_metadata)
    fill_in_key_value_for(:contact_filter_metadata, with: { key: "gender", value: "m" })
    click_action_button(:update, key: :callout_populations)

    expect(current_path).to eq(dashboard_callout_callout_population_path(callout, callout_population))
    expect(page).to have_text("Callout population was successfully updated.")
    expect(callout_population.reload.contact_filter_metadata).to eq("gender" => "m")
  end

  it "can show a callout population" do
    user = create(:user)
    callout = create(:callout, account: user.account)
    callout_population = create(
      :batch_operation,
      contact_filter_metadata: {
        location: {
          country: "Cambodia"
        }
      },
      callout: callout,
      account: user.account
    )

    sign_in(user)
    visit(dashboard_callout_callout_population_path(callout, callout_population))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_callout_callout_population_path(callout, callout_population)
      )
    end

    within("#resource") do
      expect(page).to have_link(
        callout_population.id,
        href: dashboard_callout_callout_population_path(callout, callout_population)
      )

      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Contact Filter Metadata")
      expect(page).to have_content("location:country")
      expect(page).to have_content("Cambodia")
    end
  end

  it "can delete a callout population" do
    user = create(:user)
    callout = create(:callout, account: user.account)
    callout_population = create(:callout_population, callout: callout, account: user.account)

    sign_in(user)
    visit dashboard_callout_callout_population_path(callout, callout_population)

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(dashboard_callout_callout_populations_path(callout))
    expect(page).to have_text("Callout population was successfully destroyed.")
  end
end
