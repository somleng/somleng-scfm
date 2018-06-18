require "rails_helper"

RSpec.describe "Batch Operations" do
  it "can list all batch operations" do
    user = create(:user)
    batch_operation = create_batch_operation(account: user.account)
    other_batch_operation = create_batch_operation

    sign_in(user)
    visit(dashboard_batch_operations_path)

    expect(page).to have_title("Batch Operations")

    within("#page_entries_info") do
      expect(page).to have_content("batch operation")
    end

    within("#resources") do
      expect(page).to have_content_tag_for(batch_operation)
      expect(page).not_to have_content_tag_for(other_batch_operation)
      expect(page).to have_content("#")
      expect(page).to have_link(
        batch_operation.id,
        href: dashboard_batch_operation_path(batch_operation)
      )
      have_sortable_column("type")
      have_sortable_column("status")
      have_sortable_column("created_at")
      expect(page).to have_content("Preview")
    end
  end

  it "can show a batch operation" do
    user = create(:user)
    batch_operation = create_batch_operation(account: user.account)

    sign_in(user)
    visit(dashboard_batch_operation_path(batch_operation))

    expect(page).to have_title("Batch Operation #{batch_operation.id}")

    within("#page_actions") do
      expect(page).not_to have_link_to_action(:edit)
      expect(page).not_to have_link_to_action(:preview)
    end

    within("#related_links") do
      expect(page).to have_link_to_action(
        :index,
        key: :phone_calls,
        href: dashboard_batch_operation_phone_calls_path(batch_operation)
      )
    end

    within("#resource") do
      expect(page).to have_content(batch_operation.id)
      expect(page).to have_content("Type")
      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
      expect(page).to have_content("Created at")
    end
  end

  it "can delete a batch operation" do
    user = create(:user)
    batch_operation = create_batch_operation(account: user.account)

    sign_in(user)
    visit dashboard_batch_operation_path(batch_operation)
    click_action_button(:delete, type: :link)

    expect(current_path).to eq(dashboard_batch_operations_path)
    expect(page).to have_text("successfully destroyed.")
  end

  it "can perform actions on the batch operations" do
    user = create(:user)
    batch_operation = create_batch_operation(
      :preview,
      account: user.account
    )

    sign_in(user)
    visit dashboard_batch_operation_path(batch_operation)
    clear_enqueued_jobs

    perform_enqueued_jobs do
      within("#page_actions") do
        click_action_button(:queue, key: :batch_operations, type: :link)
      end
    end

    expect(current_path).to eq(dashboard_batch_operation_path(batch_operation))
    expect(batch_operation.reload).to be_finished

    perform_enqueued_jobs do
      within("#page_actions") do
        click_action_button(:requeue, key: :batch_operations, type: :link)
      end
    end

    expect(current_path).to eq(dashboard_batch_operation_path(batch_operation))
    expect(batch_operation.reload).to be_finished
  end

  def create_batch_operation(*args)
    options = args.extract_options!
    create(
      :phone_call_create_batch_operation,
      *args,
      options
    )
  end
end
