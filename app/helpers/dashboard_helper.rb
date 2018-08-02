module DashboardHelper
  def batch_operation_create_phone_calls_default_filter_params
    default_batch_operation_filter_params = current_account.settings["batch_operation_phone_call_create_parameters"] || {}
    callout_participation_filter_params = default_batch_operation_filter_params["callout_participation_filter_params"] || {}
    callout_filter_params = default_batch_operation_filter_params.slice("callout_filter_params")
    callout_participation_filter_params.merge(callout_filter_params).presence
  end

  def location_names(province_ids, type)
    Array(province_ids).map do |location_id|
      location = type.find_by_id(location_id)
      "#{location.name_km} (#{location.name_en})" if location
    end.compact.join(", ")
  end

  def callout_status_badge(callout)
    badge_class = case callout.status.to_sym
                  when Callout::STATE_RUNNING     then "badge-success"
                  when Callout::STATE_PAUSED      then "badge-warning"
                  when Callout::STATE_STOPPED     then "badge-danger"
                  when Callout::STATE_INITIALIZED then "badge-primary"
                  end

    badge_for(callout.status.humanize, badge_class: badge_class)
  end

  def callout_trigger_method_badge(callout)
    badge_class = case callout.trigger_method
                  when :manual then "badge-info"
                  when :sensor_event then "badge-warning"
                  end

    badge_for(
      translate("simple_form.options.callout.trigger_method.#{callout.trigger_method}"),
      badge_class: badge_class
    )
  end

  private

  def badge_for(content, badge_class:)
    content_tag(:span, content, class: "badge badge-pill #{badge_class}")
  end
end
