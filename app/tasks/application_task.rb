class ApplicationTask
  def initialize(options = {})
  end

  def run!
  end

  private

  def somleng_client
    @somleng_client ||= Somleng::Client.new
  end
end
