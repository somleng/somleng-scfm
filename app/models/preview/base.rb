class Preview::Base
  attr_accessor :previewable

  def initialize(options = {})
    self.previewable = options[:previewable]
  end
end
