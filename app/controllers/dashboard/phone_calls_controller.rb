class Dashboard::PhoneCallsController < Dashboard::BaseController
  helper_method :parent_show_path

  private

  def association_chain
    if parent
      parent.phone_calls
    else
      current_account.phone_calls
    end
  end

  def parent
    if callout_participation_id
      callout_participation
    elsif callout_id
      callout
    elsif contact_id
      contact
    elsif batch_operation_id
      batch_operation
    end
  end

  def callout_participation_id
    params[:callout_participation_id]
  end

  def callout_participation
    @callout_participation ||= current_account.callout_participations.find(callout_participation_id)
  end

  def callout_id
    params[:callout_id]
  end

  def callout
    @callout ||= current_account.callouts.find(callout_id)
  end

  def contact_id
    params[:contact_id]
  end

  def contact
    @contact ||= current_account.contacts.find(contact_id)
  end

  def batch_operation_id
    params[:batch_operation_id]
  end

  def batch_operation
    @batch_operation ||= current_account.batch_operations.applies_on_phone_calls.find(
      batch_operation_id
    )
  end

  def parent_show_path
    if batch_operation_id
      dashboard_batch_operation_path(batch_operation)
    elsif parent
      polymorphic_path([:dashboard, parent])
    end
  end
end
