require "rails_helper"

RSpec.describe "Callouts" do
  it "can list all callouts" do
    filtered_callout = create(
      :callout,
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )
    create(:callout, account: account)
    create(:callout)

    get(
      api_callouts_path(
        q: {
          "metadata" => {
            "foo" => "bar"
          }
        }
      ),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(filtered_callout.id)
  end

  it "can list callouts for a contact" do
    contact = create(:contact, account: account)
    callout = create(:callout, account: account)
    _callout_participation = create_callout_participation(
      account: account,
      contact: contact,
      callout: callout
    )
    _other_callout = create(:callout, account: account)

    get(
      api_contact_callouts_path(contact),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(callout.id)
  end

  it "can create a callout" do
    request_body = {
      call_flow_logic: CallFlowLogic::HelloWorld.to_s,
      audio_file: fixture_file_upload("files/test.mp3", "audio/mp3"),
      audio_url: "https://www.example.com/sample.mp3",
      metadata: {
        "foo" => "bar"
      }
    }

    expect do
      post(
        api_callouts_path,
        params: request_body,
        headers: build_authorization_headers(access_token: access_token)
      )
    end.to have_enqueued_job(AudioFileProcessorJob)

    expect(response.code).to eq("201")
    parsed_response = JSON.parse(response.body)
    created_callout = account.callouts.find(parsed_response.fetch("id"))
    expect(created_callout.metadata).to eq(request_body.fetch(:metadata))
    expect(created_callout.call_flow_logic).to eq(request_body.fetch(:call_flow_logic))
    expect(created_callout.audio_url).to eq(request_body.fetch(:audio_url))
    expect(created_callout.audio_file).to be_attached
  end

  it "can fetch a callout" do
    callout = create(:callout, account: account)

    get(
      api_callout_path(callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("200")
    parsed_response = JSON.parse(response.body)
    expect(
      account.callouts.find(parsed_response.fetch("id"))
    ).to eq(callout)
  end

  it "can update a callout" do
    callout = create(
      :callout,
      account: account,
      metadata: {
        "foo" => "bar"
      }
    )

    request_body = { metadata: { "bar" => "foo" }, metadata_merge_mode: "replace" }

    patch(
      api_callout_path(callout),
      params: request_body,
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    callout.reload
    expect(callout.metadata).to eq(request_body.fetch(:metadata))
  end

  it "can delete a callout" do
    callout = create(:callout, account: account)

    delete(
      api_callout_path(callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("204")
    expect(Callout.find_by_id(callout.id)).to eq(nil)
  end

  it "cannot delete a callout with callout participations" do
    callout = create(:callout, account: account)
    _callout_participation = create_callout_participation(
      account: account, callout: callout
    )

    delete(
      api_callout_path(callout),
      headers: build_authorization_headers(access_token: access_token)
    )

    expect(response.code).to eq("422")
  end

  let(:account) { create(:account) }
  let(:access_token) { create_access_token(resource_owner: account) }

  def create_access_token(**options)
    create(
      :access_token,
      permissions: %i[callouts_read callouts_write],
      **options
    )
  end
end
