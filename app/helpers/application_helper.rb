module ApplicationHelper
  NOTIFICATION_STATUSES = {
    pending: { color: "gray-200", icon: "clock" },
    failed: { color: "red", icon: "alert-triangle" },
    succeeded: { color: "green", icon: "check" }
  }.freeze

  BROADCAST_STATUSES = {
    pending: { color: "gray-200", icon: "clock" },
    queued: { color: "gray-200", icon: "clock" },
    running: { color: "blue", icon: "hourglass-high" },
    stopped: { color: "yellow", icon: "player-stop-filled" },
    completed: { color: "green", icon: "check" },
    errored: { color: "red", icon: "alert-triangle" }
  }.freeze

  IMPORT_STATUSES = {
    processing: { color: "gray-200", icon: "clock" },
    failed: { color: "red", icon: "alert-triangle" },
    succeeded: { color: "green", icon: "check" }
  }.freeze

  def user_profile_image_url(user)
    if user.avatar.attached?
      url_for(user.avatar)
    else
      user_email = Digest::MD5.hexdigest(user.email)
      "https://www.gravatar.com/avatar/#{user_email}?size=200"
    end
  end

  def account_logo(account, **options)
    if account.logo&.attached?
      image_tag(account.logo, alt: "#{account.name} Logo", **options)
    else
      image_tag("open-ews_landscape_logo.png", options)
    end
  end

  def country_name(iso_country_code)
    return if iso_country_code.blank?

    country = ISO3166::Country[iso_country_code]
    country.translations[I18n.locale.to_s] || country.common_name || country.iso_short_name
  end

  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error, :alert then "alert alert-danger"
    end
  end

  def title(**options)
    default = options.fetch(:controller_name, controller_name).to_s
    default = default.singularize if options.fetch(:action_name, action_name).to_s != "index"
    default = default.to_s.humanize

    translate(
      :"titles.#{options.fetch(:controller_name, controller_name)}.#{options.fetch(:action_name, action_name)}",
      default:,
      **options
    )
  end

  def action(name, **options)
    default = name.to_s.humanize

    translate(
      :"titles.actions.#{name}",
      default:,
      **options
    )
  end

  def start_broadcast_confirmation(broadcast)
    default = "Are you sure?"

    if broadcast.channel_capabilities.any?(&:deliverable?)
      action(
        :start_broadcast_with_count,
        count: @broadcast.approximate_beneficiaries,
        default:
      )
    else
      action(:start_broadcast, default:)
    end
  end

  def sidebar_nav(text, path, icon_class:, link_options: {})
    is_active = request.path == path || (path != dashboard_root_path && request.path.start_with?(path))
    content_tag(:li, class: "nav-item #{"active" if is_active}") do
      link_to(path, class: "nav-link", **link_options) do
        content = "".html_safe
        content += content_tag(:i, nil, class: "nav-link-icon d-md-none d-lg-inline-block #{icon_class}", style: "font-size: 20px")
        content + " " + content_tag(:span, text, class: "nav-link-title")
      end
    end
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end

  def locality_tree
    iso_country_code = current_account.iso_country_code

    Rails.cache.fetch("#{iso_country_code}-#{I18n.locale}") do
      locality_data = CountryLocalityData.locality_data(iso_country_code)
      display_local_language = I18n.locale == locality_data.local_language
      locality_data.to_tree do |locality|
        {
          id: locality.value,
          text: display_local_language ? locality.name_local : locality.name_en,
          children: [],
          metadata: {
            path: locality.path,
            field_name: FieldDefinitions::GeocodeFieldMap.to_name(locality.administrative_level)
          }
        }
      end
    end
  end

  def broadcast_status(broadcast)
    status = BROADCAST_STATUSES[broadcast.status.to_sym]
    status_badge(
      broadcast.status_text,
      color: status.fetch(:color),
      icon: status.fetch(:icon)
    )
  end

  def display_value(value)
    return value if value.present?

    I18n.t(:"show_for.blank", default: "Not specified")
  end

  def notification_status(notification)
    status = NOTIFICATION_STATUSES[notification.status.to_sym]

    status_badge(
      notification.status_text,
      color: status.fetch(:color),
      icon: status.fetch(:icon)
    )
  end

  def notification_status_color(status)
    NOTIFICATION_STATUSES[status.to_sym].fetch(:color)
  end

  def import_status(import)
    status = IMPORT_STATUSES[import.status.to_sym]

    status_badge(
      import.status_text,
      color: status.fetch(:color),
      icon: status.fetch(:icon)
    )
  end

  def status_badge(text, color:, icon:)
    content_tag(:span, class: "badge bg-#{color}-lt") do
      content_tag(:i, nil, class: "icon ti ti-#{icon}") + text
    end
  end

  def pluralize_model(count, model_name, formatter: ->(count) { number_with_delimiter(count) }, locale: I18n.locale, **options)
    pluralize(formatter.call(count), model_name.human(locale:), locale:, **options).downcase
  end

  def titleize_model(model_name, **options)
    model_name.human(default: model_name.human.pluralize, **options)
  end

  def dashboard_summary_description(count, model_name, past_participle:, time_period:, unit:, locale: I18n.locale, **options)
    t(
      "dashboard_summary.stats.description",
      count:,
      model_name: pluralize_model(count, model_name, locale:),
      action: t("past_participles.#{past_participle}", locale:, default: past_participle.humanize.downcase),
      period: pluralize(time_period, t("units.#{unit}", locale:, default: unit.humanize.downcase), locale:),
      locale:,
      **options
    )
  end

  def count_of_total(count, total:, formatter: ->(count) { number_with_delimiter(count) }, **options)
    count = formatter.call(count)

    t(
      "count_of_total",
      count:,
      total:,
      default: "#{count} of #{total}",
      **options
    )
  end

  def pluralized_translations(key, **)
    translations = t(key, **)
    translations.is_a?(Hash) ? translations : { other: translations }
  end

  def error_message_for(code)
    t("error_codes.#{code}", default: code.to_s.humanize)
  end

  def format_phone_number(value)
    Phony.format(value)
  end

  def human_operator(operator)
    I18n.t("filter_operators.#{operator}")
  end

  def human_value(value, schema: nil)
    return value unless schema.respond_to?(:options_for_select)

    schema.options_for_select.find { it[1] == value }.first
  end

  def human_attribute_name(name, **options)
    translation_key = [ options[:namespace]&.downcase, name ].compact.join(".")
    ApplicationRecord.human_attribute_name(translation_key)
  end

  def mfa_qr_code(user)
    label = "OpenEWS:#{user.email}"
    content = "".html_safe
    content + RQRCode::QRCode.new(
      user.otp_provisioning_uri(label, issuer: "OpenEWS")
    ).as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 3,
      standalone: true
    ).html_safe
  end

  def user_link(user)
    return if user.blank?

    if policy(user).manage?
      link_to(user.name, dashboard_settings_user_path(user))
    else
      user.name
    end
  end
end
