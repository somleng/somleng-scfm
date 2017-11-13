class Preview::PhoneCallOperation < Preview::Base
  private

  def filter_resources(scope)
    scope.merge(callout_filter.resources).merge(callout_participation_filter.resources)
  end

  def callout_filter
    @callout_filter ||= Filter::Resource::Callout.new(
      {
        :association_chain => Callout
      },
      previewable.callout_filter_params.with_indifferent_access
    )
  end

  def callout_participation_filter
    @callout_participation_filter ||= Filter::Resource::CalloutParticipation.new(
      {
        :association_chain => CalloutParticipation
      },
      previewable.callout_participation_filter_params.with_indifferent_access
    )
  end
end
