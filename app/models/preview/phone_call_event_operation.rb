class Preview::PhoneCallEventOperation < Preview::PhoneCallOperation
  def phone_calls
    filter_resources(PhoneCall.joins(:callout_participation => :callout))
  end

  private

  def filter_resources(scope)
    super.merge(phone_call_filter.resources)
  end

  def phone_call_filter
    @phone_call_filter ||= Filter::Resource::PhoneCall.new(
      {
        :association_chain => PhoneCall
      },
      previewable.phone_call_filter_params.with_indifferent_access
    )
  end
end
