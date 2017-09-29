class CalloutsTask < ApplicationTask
  delegate :start!, :stop!, :pause!, :resume!, :to => :callout

  def self.rake_tasks
    [:start!, :stop!, :pause!, :resume!]
  end

  def callout
    @callout ||= (!ENV["CALLOUT_TASK_CALLOUT_ID"] && Callout.count == 1 && Callout.first!) || Callout.find(ENV["CALLOUT_TASK_CALLOUT_ID"])
  end
end
