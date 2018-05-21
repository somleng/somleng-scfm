require "rails_helper"

RSpec.describe "Callout Populations" do
  it "can list all the callout participations" do
    user = create(:user)
    callout_population = create(
      :callout_population, :preview,
      account: user.account
    )
    other_callout_population = create(
      :callout_population
    )

    sign_in(user)
    visit(dashboard_callout_batch_operations_path(callout_population.callout))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :new,
        key: :callout_populations,
        href: new_dashboard_callout_batch_operation_callout_population_path(
          callout_population.callout
        )
      )
      expect(page).to have_link_to_action(
        :back, href: dashboard_callout_path(callout_population.callout)
      )
      expect(page).to have_link_to_action(:index, key: :batch_operations)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(callout_population)
      expect(page).not_to have_content_tag_for(other_callout_population)
      expect(page).to have_content("#")
      expect(page).to have_link(
        callout_population.id,
        href: dashboard_batch_operation_path(callout_population)
      )
      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
    end
  end

  it "can create a callout population", :js do
    user = create(:user)
    callout = create(:callout, account: user.account)

    sign_in(user)
    visit(new_dashboard_callout_batch_operation_callout_population_path(callout))

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.callout_populations.new"),
        href: new_dashboard_callout_batch_operation_callout_population_path(callout)
      )
    end

    expect(page).to have_link_to_action(:cancel)

    fill_in_key_value_for(
      :contact_filter_metadata,
      with: { key: "gender", value: "f" },
      index: 0
    )
    add_key_value_for(:contact_filter_metadata)
    fill_in_key_value_for(
      :contact_filter_metadata,
      with: { key: "location:country", value: "kh" },
      index: 1
    )
    click_action_button(:create, key: :callout_populations)

    new_callout_population = callout.reload.callout_populations.last!
    expect(current_path).to eq(dashboard_batch_operation_path(new_callout_population))
    expect(page).to have_text("Callout population was successfully created")
    asserted_contact_filter_metadata = { "gender" => "f", "location" => { "country" => "kh" } }
    expect(new_callout_population.contact_filter_metadata).to eq(asserted_contact_filter_metadata)
  end

  it "can update a callout population", :js do
    user = create(:user)
    callout_population = create_callout_population(
      user.account,
      "gender" => "f",
      "location" => {
        "country_code" => "kh"
      }
    )

    sign_in(user)
    visit(
      edit_dashboard_batch_operation_callout_population_path(
        callout_population
      )
    )

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.callout_populations.edit"),
        href: edit_dashboard_batch_operation_callout_population_path(
          callout_population
        )
      )
    end

    expect(page).to have_link_to_action(:cancel)

    remove_key_value_for(:contact_filter_metadata)
    remove_key_value_for(:contact_filter_metadata)
    add_key_value_for(:contact_filter_metadata)
    fill_in_key_value_for(:contact_filter_metadata, with: { key: "gender", value: "m" })
    click_action_button(:update, key: :callout_populations)

    expect(current_path).to eq(dashboard_batch_operation_path(callout_population))
    expect(page).to have_text("Callout population was successfully updated.")
    expect(callout_population.reload.contact_filter_metadata).to eq("gender" => "m")
  end

  it "can show a callout population" do
    user = create(:user)
    callout_population = create_callout_population(
      user.account,
      location: {
        country: "Cambodia"
      }
    )

    sign_in(user)
    visit(dashboard_batch_operation_path(callout_population))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :index,
        key: :callout_participations,
        href: dashboard_batch_operation_callout_participations_path(
          callout_population
        )
      )

      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_batch_operation_callout_population_path(
          callout_population
        )
      )
    end

    within("#resource") do
      expect(page).to have_content(callout_population.id)

      expect(page).to have_link(
        callout_population.callout.id,
        href: dashboard_callout_path(callout_population.callout)
      )

      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
      expect(page).to have_content("Callout")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Contact filter metadata")
      expect(page).to have_content("location:country")
      expect(page).to have_content("Cambodia")
    end
  end

  it "can preview a callout population" do
    user = create(:user)
    female_contact = create_contact(user.account, "gender" => "f")
    male_contact = create_contact(user.account, "gender" => "m")
    callout_population = create_callout_population(
      user.account, "gender": "f"
    )

    sign_in(user)
    visit dashboard_batch_operation_preview_contacts_path(callout_population)

    within("#button_toolbar") do
      expect(page).to have_link_to_action(:preview)
      expect(page).to have_link_to_action(
        :back,
        href: dashboard_batch_operation_path(
          callout_population
        )
      )
    end

    expect(page).to have_content_tag_for(female_contact)
    expect(page).not_to have_content_tag_for(male_contact)
  end

  it "can delete a callout population" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)

    sign_in(user)
    visit dashboard_batch_operation_path(callout_population)

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(
      dashboard_callout_batch_operations_path(callout_population.callout)
    )
    expect(page).to have_text("successfully destroyed.")
  end

  it "cannot delete a callout population with callout participations" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)
    create(:callout_participation, callout_population: callout_population)

    sign_in(user)
    visit dashboard_batch_operation_path(callout_population)

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(
      dashboard_batch_operation_path(callout_population)
    )
    expect(page).to have_text("could not be destroyed")
  end

  def create_callout_population(account, contact_filter_metadata)
    create(
      :callout_population,
      account: account,
      contact_filter_metadata: contact_filter_metadata
    )
  end

  def create_contact(account, metadata)
    create(
      :contact,
      account: account,
      metadata: metadata
    )
  end
end
