require 'rails_helper'

RSpec.describe "GET '/callout/:callout_id/statistics'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:callout) { create(:callout) }
  let(:url) { api_callout_callout_statistics_path(callout) }
  let(:asserted_parsed_json) { JSON.parse(CalloutStatistics.new(:callout => callout).to_json) }

  def setup_scenario
    super
    do_request(:get, url)
  end

  def assert_show!
    expect(response.code).to eq("200")
    expect(JSON.parse(response.body)).to eq(asserted_parsed_json)
  end

  it { assert_show! }
end
