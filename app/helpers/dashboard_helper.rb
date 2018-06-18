module DashboardHelper
  def nav_link(link_text, link_path, controllers)
    class_names = ["nav-link"]
    class_names << "active" if controllers.include?(controller_name)

    content_tag(:li, class: "nav-item") do
      link_to link_path, class: class_names.join(" ") do
        fa_icon fa_name(controllers), text: link_text
      end
    end
  end

  private

  def fa_name(name)
    case name
    when "access_tokens" then "key"
    when "batch_operations" then "tasks"
    when "callouts" then "bullhorn"
    when "callout_participations" then "list-ol"
    when "contacts" then "address-book"
    when "phone_calls" then "info-circle"
    when "remote_phone_call_events" then "calendar-alt"
    when "users" then "users"
    end
  end
end
