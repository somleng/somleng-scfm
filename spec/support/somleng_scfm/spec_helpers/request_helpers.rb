module SomlengScfm::SpecHelpers::RequestHelpers
  def do_request(method, path, body = {}, headers = {}, options = {})
    public_send(method, path, {:params => body, :headers => headers}.merge(options))
  end

  def assert_index!
    expect(response.code).to eq("200")
    expect(response.headers["Per-Page"]).to eq("25")
  end
end
