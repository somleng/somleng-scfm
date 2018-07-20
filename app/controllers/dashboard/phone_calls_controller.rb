class Dashboard::PhoneCallsController < Dashboard::BaseController
  private

  def association_chain
    if parent_resource
      parent_resource.phone_calls
    else
      current_account.phone_calls
    end
  end

  def parent_resource
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

  def filter_class
    Filter::Resource::PhoneCall
  end
end
