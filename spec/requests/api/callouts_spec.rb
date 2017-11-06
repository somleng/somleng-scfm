require 'rails_helper'

RSpec.describe "GET '/api/callouts'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:asserted_resources) { [] }
  let(:asserted_count) { asserted_resources.count }
  let(:asserted_body) { asserted_resources.to_json }
  let(:url_params) { {} }

  def setup_scenario
    super
    do_request(:get, api_callouts_path(url_params))
  end

  def assert_index!
    super
    expect(response.headers["Total"]).to eq(asserted_count.to_s)
    expect(response.body).to eq(asserted_body)
  end

  it_behaves_like "authorization"
  it_behaves_like "index_filtering" do
    let(:filter_on_factory) { :callout }
  end
end
