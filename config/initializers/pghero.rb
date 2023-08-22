ENV["PGHERO_USERNAME"] = Rails.configuration.app_settings.fetch(:admin_username)
ENV["PGHERO_PASSWORD"] = Rails.configuration.app_settings.fetch(:admin_password)
