require "rails_helper"

RSpec.describe "Contacts", :aggregate_failures do
  it "can list all contacts" do
    user = create(:user)
    contact = create(:contact, account: user.account)
    other_contact = create(:contact)

    sign_in(user)
    visit dashboard_contacts_path

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :new, key: :contacts, href: new_dashboard_contact_path
      )
      expect(page).to have_link_to_action(:index, key: :contacts)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(contact)
      expect(page).not_to have_content_tag_for(other_contact)
      expect(page).to have_content("#")
      expect(page).to have_link(
        contact.id,
        href: dashboard_contact_path(contact)
      )
      expect(page).to have_content("Phone Number")
    end
  end

  it "can create a new contact" do
    user = create(:user)
    phone_number = generate(:somali_msisdn)

    sign_in(user)
    visit new_dashboard_contact_path

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.contacts.new"),
        href: new_dashboard_contact_path
      )
    end

    expect(page).to have_link_to_action(:cancel)

    click_action_button(:create, key: :contacts)

    expect(page).to have_content("Phone Number can't be blank")

    fill_in("Phone Number", with: phone_number)
    fill_in_key_value_for(:metadata, with: { key: "name", value: "Bob Chann" })
    click_action_button(:create, key: :contacts)

    expect(page).to have_text("Contact was successfully created.")
    new_contact = user.reload.account.contacts.last!
    expect(new_contact.msisdn).to match(phone_number)
    expect(new_contact.metadata).to eq("name" => "Bob Chann")
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

    within("#button_toolbar") do
      expect(page).to have_link(
        I18n.translate!(:"titles.contacts.edit"),
        href: edit_dashboard_contact_path(contact)
      )
    end

    expect(page).to have_link_to_action(:cancel)

    updated_phone_number = generate(:somali_msisdn)
    fill_in("Phone Number", with: updated_phone_number)
    remove_key_value_for(:metadata)
    remove_key_value_for(:metadata)
    add_key_value_for(:metadata)
    fill_in_key_value_for(:metadata, with: { key: "gender", value: "f" })
    click_action_button(:update, key: :contacts)

    expect(current_path).to eq(dashboard_contact_path(contact))
    expect(page).to have_text("Contact was successfully updated.")
    expect(contact.reload.msisdn).to match(updated_phone_number)
    expect(contact.metadata).to eq("gender" => "f")
  end

  it "can delete a contact" do
    user = create(:user)
    contact = create(:contact, account: user.account)

    sign_in(user)
    visit dashboard_contact_path(contact)

    click_action_button(:delete, type: :link)

    expect(current_path).to eq(dashboard_contacts_path)
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

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_contact_path(contact)
      )
    end

    within("#contact") do
      expect(page).to have_content(contact.id)
      expect(page).to have_content("#")
      expect(page).to have_content("Phone Number")
      expect(page).to have_content(phone_number)
      expect(page).to have_content("Metadata")
      expect(page).to have_content("location:country")
      expect(page).to have_content("Cambodia")
    end
  end
end
