require 'rails_helper'

RSpec.describe "Callout Participations" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:callout) { create(:callout) }
  let(:body) { {} }
  let(:factory_attributes) { {} }
  let(:callout_participation) { create(:callout_participation, factory_attributes) }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  def assert_filtered!
    assert_index!
    expect(JSON.parse(response.body)).to eq(JSON.parse([callout_participation].to_json))
  end

  def setup_filtering_scenario
    callout_participation
    create(:callout_participation)
  end

  describe "GET '/callout_participations'" do
    let(:url_params) { {} }
    let(:url) { api_callout_participations_path(url_params) }
    let(:method) { :get }

    context "filtering" do
      def setup_scenario
        setup_filtering_scenario
        super
      end

      context "by misisdn" do
        let(:msisdn) { generate(:somali_msisdn) }
        let(:factory_attributes) { {:msisdn => msisdn} }
        let(:url_params) { { :msisdn => msisdn } }
        it { assert_filtered! }
      end

      context "by callout_id" do
        let(:callout) { create(:callout) }
        let(:factory_attributes) { { :callout => callout } }
        let(:url_params) { { :callout_id => callout.id } }
        it { assert_filtered! }
      end

      context "by contact_id" do
        let(:contact) { create(:contact) }
        let(:factory_attributes) { { :contact => contact } }
        let(:url_params) { { :contact_id => contact.id } }
        it { assert_filtered! }
      end

      context "by callout_population_id" do
        let(:callout_population) { create(:callout_population) }
        let(:factory_attributes) { { :callout_population => callout_population } }
        let(:url_params) { { :callout_population_id => callout_population.id } }
        it { assert_filtered! }
      end
    end

    it_behaves_like "metadata_filtering" do
      let(:filter_on_factory) { :callout_participation }
    end

    it_behaves_like "authorization"
  end

  describe "nested index" do
    let(:method) { :get }

    def setup_scenario
      setup_filtering_scenario
      super
    end

    describe "GET '/api/callout/:callout_id/callout_participations'" do
      let(:url) { api_callout_callout_participations_path(callout) }
      let(:factory_attributes) { { :callout => callout } }
      it { assert_filtered! }
    end

    describe "GET '/api/contact/:contact_id/callout_participations'" do
      let(:contact) { create(:contact) }
      let(:url) { api_contact_callout_participations_path(contact) }
      let(:factory_attributes) { { :contact => contact } }
      it { assert_filtered! }
    end

    describe "GET '/api/callout_population/:callout_population_id/callout_participations'" do
      let(:callout_population) { create(:callout_population) }
      let(:url) { api_callout_population_callout_participations_path(callout_population) }
      let(:factory_attributes) { { :callout_population => callout_population } }
      it { assert_filtered! }
    end
  end
end
