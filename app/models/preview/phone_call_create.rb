class Preview::PhoneCallCreate < Preview::PhoneCallOperation
  def callout_participations(scope:)
    filter_resources(scope: scope.joins(:callout))
  end

  def contacts(scope:)
    filter_resources(scope: scope.joins(:callouts).joins(:callout_participations))
  end
end
