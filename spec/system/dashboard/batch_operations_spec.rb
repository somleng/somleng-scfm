require "rails_helper"

RSpec.describe "Batch Operations" do
  it "can list all the batch operatations" do
    user = create(:user)
    batch_operation = create(:batch_operation, :preview, account: user.account)
    other_batch_operation = create(:batch_operation)

    sign_in(user)
    visit(dashboard_batch_operations_path)

    within("#page_title") do
      expect(page).to have_content(I18n.translate!(:"titles.batch_operations.index"))
    end

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :new, key: :batch_operations, href: new_dashboard_batch_operation_path
      )
    end

    within("#batch_operations") do
      expect(page).to have_content_tag_for(batch_operation, model_name: :batch_operation)
      expect(page).not_to have_content_tag_for(other_batch_operation, model_name: :batch_operation)
      expect(page).to have_content("#")
      expect(page).to have_link(
        batch_operation.id,
        href: dashboard_batch_operation_path(batch_operation)
      )
      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
    end
  end

  it "can show a batch operation" do
    user = create(:user)
    batch_operation = create(
      :batch_operation,
      metadata: {
        location: {
          country: "Cambodia"
        }
      },
      account: user.account
    )

    sign_in(user)
    visit(dashboard_batch_operation_path(batch_operation))

    within("#button_toolbar") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_batch_operation_path(batch_operation)
      )
    end

    within("#batch_operation") do
      expect(page).to have_link(
        callout.id,
        href: dashboard_batch_operation_path(batch_operation)
      )

      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
      expect(page).to have_content("Created at")
      expect(page).to have_content("Metadata")
      expect(page).to have_content("location:country")
      expect(page).to have_content("Cambodia")
    end
  end
end
