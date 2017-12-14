class CallFlowLogic::AvfCapom::CapomShort < CallFlowLogic::AvfCapom::CapomBase
  aasm :whiny_transitions => false do
    state :initialized, :initial => true
    state :playing_introduction
    state :gathering_received_transfer
    state :recording_transfer_not_received_reason
    state :playing_transfer_not_received_exit_message
    state :finished
    state :gathering_fee_paid
    state :gathering_fee_paid_amount
    state :recording_goods_purchased
    state :gathering_safe_at_venue
    state :playing_completed_survey_message

    before_all_events :set_current_state
    after_all_events :set_status

    event :step do
      before :set_previous_status

      transitions :from => :initialized,
                  :to => :playing_introduction

      transitions :from => :playing_introduction,
                  :to =>   :gathering_received_transfer

      transitions :from => :gathering_received_transfer,
                  :to => :recording_transfer_not_received_reason,
                  :if => :answered_no?

      transitions :from => :recording_transfer_not_received_reason,
                  :to => :playing_transfer_not_received_exit_message

      transitions :from => :playing_transfer_not_received_exit_message,
                  :to => :finished

      transitions :from => :gathering_received_transfer,
                  :to => :gathering_fee_paid,
                  :if => :answered_yes?

      transitions :from => :gathering_fee_paid,
                  :to => :gathering_fee_paid_amount,
                  :if => :answered_yes?

      transitions :from => :gathering_fee_paid,
                  :to => :recording_goods_purchased,
                  :if => :answered_no?

      transitions :from => :gathering_fee_paid_amount,
                  :to => :recording_goods_purchased,
                  :if => :answered_any?

      transitions :from => :recording_goods_purchased,
                  :to => :gathering_safe_at_venue

      transitions :from => :gathering_safe_at_venue,
                  :to => :playing_completed_survey_message,
                  :if => :answered_yes_or_no?

      transitions :from => :playing_completed_survey_message,
                  :to => :finished
    end
  end
end
