class Preview::Base
  attr_accessor :previewable

  def initialize(previewable:)
    self.previewable = previewable
  end
end
