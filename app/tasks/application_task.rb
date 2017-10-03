class ApplicationTask
  def initialize(options = {})
  end

  class Install
    DEFAULT_ENV_VARS = {
      :rails_env => "production",
      :phone_call_time_considered_recently_created_seconds => "60"
    }

    DEFAULT_SOMLENG_ENV_VARS = {
      :somleng_client_rest_api_host => "api.twilio.com",
      :somleng_client_rest_api_base_url => "https://api.twilio.com",
      :somleng_account_sid => "replace-me-account-sid",
      :somleng_auth_token =>"replace-me-auth-token"
    }

    DEFAULT_RAPIDPRO_ENV_VARS = {
      :rapidpro_base_url => "https://app.rapidpro.io/api",
      :rapidpro_api_version => "v2",
      :rapidpro_api_token => "change-me-rapidpro-api-token"
    }

    def self.rake_tasks
      [:run!]
    end

    def self.task_namespace
      self.to_s.deconstantize.underscore
    end

    def self.rake_task_namespace
      task_namespace.sub(/_task$/, "")
    end

    def self.rake_task_name(name)
      name.to_s.sub(/[!\?]$/, "")
    end

    def self.rake_task_invocation_name(name)
      ["task", rake_task_namespace, rake_task_name(name)].join(":")
    end

    def self.cron_name(name)
      [task_namespace, rake_task_name(name)].join("_")
    end

    def self.install_cron?(task_name)
      true
    end

    def self.default_somleng_env_vars(task_name)
      DEFAULT_SOMLENG_ENV_VARS
    end

    def self.default_env_vars(task_name)
      DEFAULT_ENV_VARS
    end
  end
end
