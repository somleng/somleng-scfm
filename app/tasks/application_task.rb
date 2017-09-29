class ApplicationTask
  def initialize(options = {})
  end

  def run!
  end

  def self.rake_tasks
    [:run!]
  end
end
