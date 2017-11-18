require 'rails_helper'

RSpec.describe CallFlowLogic::OutcomeMonitoring do

  let(:phone_call) { create(:phone_call, phone_call_factory_attributes) }
  let(:event_details) { generate(:twilio_remote_call_event_details) }
  let(:event_factory_attributes) { { :details => event_details, :phone_call => phone_call } }
  let(:event) { create(:remote_phone_call_event, event_factory_attributes) }

  let(:status) { nil }
  let(:call_flow_data) { { "status" => status } }
  let(:contact_metadata) { { "call_flow_data" => { described_class.to_s => call_flow_data } } }
  let(:contact) { create(:contact, :metadata => contact_metadata) }
  let(:phone_call_factory_attributes) { { :contact => contact } }

  let(:current_url) { "http://scfm.example.com/api/remote_phone_call_events" }
  subject { described_class.new(:event => event, :current_url => current_url) }

  describe "state_machine" do
    context "by default" do
      it { is_expected.to be_initialized }
    end
  end

  describe "#run!" do
    let(:new_call_flow_data) {
      contact.reload.metadata["call_flow_data"][described_class.to_s]
    }

    def event_details_with_response(response, event_details)
      if response == :yes
        event_details.merge("Digits" => "1")
      elsif response == :no
        event_details.merge("Digits" => "2")
      else
        event_details.merge("Digits" => "0")
      end
    end

    def setup_scenario
      super
      subject.run!
    end

    def assert_run!
      expect(subject.status).to eq(asserted_new_status.to_s)
      expect(new_call_flow_data["status"]).to eq(asserted_new_status.to_s)
      expect(new_call_flow_data["transitioned_to_#{asserted_new_status}_by"]).to eq(event.id) if asserted_new_status != status
    end

    context "status: nil" do
      let(:status) { nil }
      let(:asserted_new_status) { described_class::STATE_PLAYING_INTRODUCTION }
      it { assert_run! }
    end

    context "status: '#{described_class::STATE_PLAYING_INTRODUCTION}'" do
      let(:status) { described_class::STATE_PLAYING_INTRODUCTION }
      let(:asserted_new_status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER }
      it { assert_run! }
    end

    context "status: '#{described_class::STATE_GATHERING_RECEIVED_TRANSFER}'" do
      let(:status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER }

      context "answered yes" do
        let(:event_details) { event_details_with_response(:yes, super()) }
        let(:asserted_new_status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT }

        it { assert_run! }
      end

      context "answered no" do
        let(:event_details) { event_details_with_response(:no, super()) }
        let(:asserted_new_status) { described_class::STATE_RECORDING_TRANSFER_NOT_RECEIVED_REASON }
        it { assert_run! }
      end

      context "no answer" do
        let(:event_details) { event_details_with_response(nil, super()) }
        let(:asserted_new_status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER }
        it { assert_run! }
      end
    end

    context "status: '#{described_class::STATE_RECORDING_TRANSFER_NOT_RECEIVED_REASON}'" do
      let(:status) { described_class::STATE_RECORDING_TRANSFER_NOT_RECEIVED_REASON }
      let(:asserted_new_status) { described_class::STATE_PLAYING_TRANSFER_NOT_RECEIVED_EXIT_MESSAGE }
      it { assert_run! }
    end

    context "status: '#{described_class::STATE_PLAYING_TRANSFER_NOT_RECEIVED_EXIT_MESSAGE}'" do
      let(:status) { described_class::STATE_PLAYING_TRANSFER_NOT_RECEIVED_EXIT_MESSAGE }
      let(:asserted_new_status) { described_class::STATE_FINISHED }
      it { assert_run! }
    end
  end

  describe "#to_xml" do
    let(:xml) { subject.to_xml }
    let(:response) { Hash.from_xml(xml)["Response"] }
    let(:gather_response) { response["Gather"] }

    def asserted_play_file_url(filename)
      [
        described_class::DEFAULT_PLAY_FILE_BASE_URL,
        filename.to_s + described_class::DEFAULT_PLAY_FILE_EXTENSION
      ].join("/")
    end

    def assert_xml!
      expect(response).to be_present
    end

    def assert_play_status_and_redirect!
      expect(response["Play"]).to eq(asserted_play_file_url(status))
      expect(response["Redirect"]).to eq(current_url)
    end

    def assert_finished!
      expect(response["Play"]).to eq(asserted_play_file_url(:survey_is_already_finished))
      expect(response).to have_key("Hangup")
    end

    context "status: nil" do
      let(:status) { nil }

      def assert_xml!
        super
        expect(response["Say"]).to eq("Sorry. The application has no response. Goodbye.")
      end

      it { assert_xml! }
    end

    context "status: '#{described_class::STATE_PLAYING_INTRODUCTION}'" do
      let(:status) { described_class::STATE_PLAYING_INTRODUCTION }

      def assert_xml!
        super
        assert_play_status_and_redirect!
      end

      it { assert_xml! }
    end

    context "status: '#{described_class::STATE_GATHERING_RECEIVED_TRANSFER}'" do
      let(:status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER }

      def assert_xml!
        super
        expect(gather_response).to be_present
        expect(gather_response["numDigits"]).to eq("1")
      end

      context "no status change" do
        let(:previous_status) { status }

        def setup_scenario
          super
          subject.previous_status = status
          subject.aasm.current_state = status.to_sym
        end

        def assert_xml!
          super
          expect(gather_response["Play"]).to eq(
            [
              asserted_play_file_url(:did_not_understand_response),
              asserted_play_file_url(status)
            ]
          )
        end

        it { assert_xml! }
      end

      context "status changed" do
        def assert_xml!
          super
          expect(gather_response["Play"]).to eq(asserted_play_file_url(status))
        end

        it { assert_xml! }
      end
    end

    context "status: '#{described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT}'" do
      let(:status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT }

      def assert_xml!
        super
        expect(gather_response).to be_present
        expect(gather_response["numDigits"]).to eq("3")
        expect(gather_response["Play"]).to eq(asserted_play_file_url(status))
      end

      it { assert_xml! }
    end

    context "status: '#{described_class::STATE_RECORDING_TRANSFER_NOT_RECEIVED_REASON}'" do
      let(:status) { described_class::STATE_RECORDING_TRANSFER_NOT_RECEIVED_REASON }

      def assert_xml!
        super
        expect(response["Play"]).to eq(asserted_play_file_url(status))
        expect(response).to have_key("Record")
      end

      it { assert_xml! }
    end

    context "status: '#{described_class::STATE_PLAYING_TRANSFER_NOT_RECEIVED_EXIT_MESSAGE}'" do
      let(:status) { described_class::STATE_PLAYING_TRANSFER_NOT_RECEIVED_EXIT_MESSAGE }

      def assert_xml!
        super
        assert_play_status_and_redirect!
      end

      it { assert_xml! }
    end

    context "status: '#{described_class::STATE_FINISHED}'" do
      let(:status) { described_class::STATE_FINISHED }

      def assert_xml!
        super
        assert_finished!
      end

      it { assert_xml! }
    end
  end
end
