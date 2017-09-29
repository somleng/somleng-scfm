class ApplicationTask
  def initialize(options = {})
  end

  def self.install_cron?
    true
  end

  def self.rake_task_namespace
    self.to_s.underscore.sub(/_task$/, "")
  end

  def self.rake_task_name(name)
    name.to_s.sub(/[!\?]$/, "")
  end

  def self.rake_task_invocation_name(name)
    ["task", rake_task_namespace, rake_task_name(name)].join(":")
  end

  def self.cron_name(name)
    [self.to_s.underscore, rake_task_name(name)].join("_")
  end
end
