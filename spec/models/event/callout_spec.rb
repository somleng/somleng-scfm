require 'rails_helper'

RSpec.describe Event::Callout do
  let(:eventable_factory) { :callout }

  it_behaves_like("resource_event") do
    let(:event) { "start" }
    let(:asserted_current_status) { Callout::STATE_INITIALIZED }
    let(:asserted_new_status) { Callout::STATE_RUNNING }
  end
end
