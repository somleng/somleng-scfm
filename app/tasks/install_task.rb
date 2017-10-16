class InstallTask < ApplicationTask
  DEFAULT_DOCKER_IMAGE_NAME = "dwilkie/somleng-scfm"
  DEFAULT_HOST_INSTALL_DIR = "/etc/somleng-scfm"
  DEFAULT_DOCKER_RUN_COMMAND = "docker run"

  class Install < ApplicationTask::Install
    def self.rake_tasks
      [:cron]
    end

    def self.install_cron?(task_name)
      false
    end
  end

  def cron
    dir = ["install", "cron"]
    mk_install_dir(*dir)

    ApplicationTask.descendants.each do |task_class|
      task_class::Install.rake_tasks.each do |rake_task|
        next if !task_class::Install.install_cron?(rake_task)
        output_path = container_path(*dir, task_class::Install.cron_name(rake_task))
        File.write(output_path, cron_entry(task_class::Install, rake_task))
        FileUtils.chmod(0764, output_path)
      end
    end
  end

  private

  def mk_install_dir(*args)
    FileUtils.mkdir_p(container_path(*args))
  end

  def cron_entry(task_class, rake_task)
    "# The newline at the end of this file is extremely important. Cron won't run without it.\n* * * * * root #{full_docker_command(task_class, rake_task)}\n"
  end

  def full_docker_command(task_class, rake_task)
    "#{docker_run_command} #{docker_flags(task_class, rake_task)} #{docker_image_name} #{docker_command(task_class, rake_task)}"
  end

  def container_path(*args)
    Rails.root.join(*args)
  end

  def default_docker_flags(task_class, rake_task)
    [
      "--rm",
      "-v #{host_database_dir}:#{container_path('db')}",
      docker_env_flags(task_class, rake_task).presence
    ].compact.join(" ")
  end

  def docker_env_flags(task_class, rake_task)
    ENV["DOCKER_ENV_FLAGS"] || default_docker_env_flags(task_class, rake_task)
  end

  def default_docker_env_flags(task_class, rake_task)
    task_class.default_env_vars(rake_task).map { |var, value|
      "-e #{var.upcase}=\"#{value}\""
    }.join(" ")
  end

  def docker_flags(task_class, rake_task)
    ENV["DOCKER_FLAGS"] || default_docker_flags(task_class, rake_task)
  end

  def docker_command(task_class, rake_task)
    ENV["DOCKER_COMMAND"] || default_docker_command(task_class, rake_task)
  end

  def default_docker_command(task_class, rake_task)
    "/bin/bash -c 'bundle exec rake #{task_class.rake_task_invocation_name(rake_task)}'"
  end

  def docker_run_command
    ENV["DOCKER_RUN_COMMAND"] || DEFAULT_DOCKER_RUN_COMMAND
  end

  def host_database_dir
    ENV["HOST_DATABASE_DIR"] || File.join(host_install_dir, "db")
  end

  def host_install_dir
    ENV["HOST_INSTALL_DIR"] || DEFAULT_HOST_INSTALL_DIR
  end

  def docker_image_name
    ENV["DOCKER_IMAGE_NAME"] || DEFAULT_DOCKER_IMAGE_NAME
  end
end
