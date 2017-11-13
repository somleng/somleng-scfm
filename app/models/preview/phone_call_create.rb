class Preview::PhoneCallCreate < Preview::PhoneCallOperation
  def callout_participations
    filter_resources(CalloutParticipation.joins(:callout))
  end

  def contacts
    filter_resources(Contact.joins(:callouts).joins(:callout_participations))
  end
end
