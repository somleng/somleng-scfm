require "rails_helper"

RSpec.describe "Contacts", :aggregate_failures do
  it "can list all contacts" do
    user = create(:user)
    contact = create(:contact, account: user.account)
    other_contact = create(:contact)

    sign_in(user)
    visit dashboard_contacts_path

    expect(page).to have_title("Contacts")

    within("#page_actions") do
      expect(page).to have_link("New", href: new_dashboard_contact_path)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(contact)
      expect(page).not_to have_content_tag_for(other_contact)
      expect(page).to have_content("#")
      expect(page).to have_link(
        contact.id.to_s,
        href: dashboard_contact_path(contact)
      )

      expect(page).to have_sortable_column("msisdn")
      expect(page).to have_sortable_column("created_at")
    end
  end

  it "can create a new contact" do
    user = create(:user)
    phone_number = generate(:somali_msisdn)

    sign_in(user)
    visit new_dashboard_contact_path

    expect(page).to have_title("New Contact")

    click_on("Create Contact")

    expect(page).to have_content("Phone number must be filled")

    fill_in("Phone number", with: phone_number)
    fill_in_key_value_for(:metadata, with: { key: "name", value: "Bob Chann" })
    click_on("Create Contact")

    expect(page).to have_text("Contact was successfully created.")
    expect(page).to have_content(phone_number)
    expect(page).to have_content("Bob Chann")
  end

  it "can update a contact", :js do
    user = create(:user)
    contact = create(
      :contact,
      account: user.account,
      metadata: {
        "location" => { "country" => "kh", "city" => "Phnom Penh" }
      }
    )

    sign_in(user)
    visit edit_dashboard_contact_path(contact)

    expect(page).to have_title("Edit Contact")

    updated_phone_number = generate(:somali_msisdn)
    fill_in("Phone number", with: updated_phone_number)
    remove_key_value_for(:metadata)
    remove_key_value_for(:metadata)
    add_key_value_for(:metadata)
    fill_in_key_value_for(:metadata, with: { key: "gender", value: "female" })
    click_on("Save")

    expect(page).to have_content("Contact was successfully updated.")
    expect(page).to have_content(updated_phone_number)
    expect(page).to have_content("female")
  end

  it "can delete a contact" do
    user = create(:user)
    contact = create(:contact, account: user.account)

    sign_in(user)
    visit dashboard_contact_path(contact)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_contacts_path, ignore_query: true)
    expect(page).to have_text("Contact was successfully destroyed.")
  end

  it "can show a contact" do
    user = create(:user)
    phone_number = generate(:somali_msisdn)
    contact = create(
      :contact,
      account: user.account,
      msisdn: phone_number,
      metadata: { "location" => { "country" => "Cambodia" } }
    )

    sign_in(user)
    visit dashboard_contact_path(contact)

    expect(page).to have_title("Contact #{contact.id}")

    within("#page_actions") do
      expect(page).to have_link("Edit", href: edit_dashboard_contact_path(contact))
    end

    within("#related_links") do
      expect(page).to have_link(
        "Callout Participations",
        href: dashboard_contact_callout_participations_path(contact)
      )

      expect(page).to have_link(
        "Phone Calls",
        href: dashboard_contact_phone_calls_path(contact)
      )
    end

    within(".contact") do
      expect(page).to have_content(contact.id)
      expect(page).to have_content("Cambodia")
    end
  end
end
