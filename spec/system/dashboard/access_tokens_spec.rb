require "rails_helper"

RSpec.describe "API Key Management" do
  it "can list api keys" do
    user = create(:user)
    sign_in(user)
    access_token = create(:access_token, resource_owner: user.account)
    other_access_token = create(:access_token)

    visit(dashboard_access_tokens_path)

    expect(page).to have_title("API Keys")

    within("#page_actions") do
      expect(page).to have_link("New", href: new_dashboard_access_token_path)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(access_token)
      expect(page).not_to have_content_tag_for(other_access_token)
      expect(page).to have_content("API key")
      expect(page).to have_content("Permissions")
      expect(page).to have_content(access_token.token)
      expect(page).to have_link(
        access_token.id.to_s,
        href: dashboard_access_token_path(access_token)
      )
    end
  end

  it "can create a new access token" do
    user = create(:user)

    sign_in(user)
    visit(new_dashboard_access_token_path)

    check("Write contacts")
    check("Read batch operations")

    click_on("Create API key")

    expect(page).to have_content("API key was successfully created.")
    new_access_token = user.account.access_tokens.first!
    expect(new_access_token).to be_persisted
    expect(page).to have_current_path(
      dashboard_access_token_path(new_access_token),
      ignore_query: true
    )
    expect(new_access_token.permissions).to match_array(
      %i[
        batch_operations_read
        contacts_write
      ]
    )
  end

  it "can show an access token" do
    user = create(:user)
    access_token = create(
      :access_token,
      resource_owner: user.account,
      permissions: %i[
        batch_operations_read
        contacts_write
      ]
    )

    sign_in(user)
    visit dashboard_access_token_path(access_token)

    within("#page_actions") do
      expect(page).to have_link("Edit", href: edit_dashboard_access_token_path(access_token))
    end

    within(".access_token") do
      expect(page).to have_content(access_token.token)
      expect(page).to have_content("Read batch operations, Write contacts")
    end
  end

  it "can update an access token" do
    user = create(:user)
    access_token = create(
      :access_token,
      resource_owner: user.account,
      permissions: %i[
        batch_operations_read
        contacts_write
      ]
    )

    sign_in(user)
    visit edit_dashboard_access_token_path(access_token)

    uncheck("Write contacts")
    check("Write callouts")
    click_on("Save")

    expect(page).to have_text("API key was successfully updated.")
    expect(page).to have_current_path(dashboard_access_token_path(access_token), ignore_query: true)
    expect(access_token.reload.permissions).to match_array(%i[batch_operations_read callouts_write])
  end

  it "can delete an access token" do
    user = create(:user)
    access_token = create(:access_token, resource_owner: user.account)

    sign_in(user)
    visit(dashboard_access_token_path(access_token))

    within("#page_actions") do
      click_on "Delete"
    end

    expect(page).to have_current_path(dashboard_access_tokens_path, ignore_query: true)
    expect(AccessToken.find_by_id(access_token.id)).to eq(nil)
  end
end
