module DashboardHelper
  def batch_operation_create_phone_calls_default_filter_params
    default_batch_operation_filter_params = current_account.settings["batch_operation_phone_call_create_parameters"] || {}
    callout_participation_filter_params = default_batch_operation_filter_params["callout_participation_filter_params"] || {}
    callout_filter_params = default_batch_operation_filter_params.slice("callout_filter_params")
    callout_participation_filter_params.merge(callout_filter_params).presence
  end

  def nav_link(link_text, link_path, controller_names:, icon:)
    class_names = ["nav-link"]
    class_names << "active" if controller_names.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to(link_path, class: class_names.join(" ")) do
        fa_icon(icon, text: link_text)
      end
    end
  end
end
