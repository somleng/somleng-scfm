class ApplicationTask
  def initialize(options = {})
  end

  class Install
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

    def self.install_cron?
      true
    end

    def self.default_env_vars(task_name)
      {}
    end
  end
end
