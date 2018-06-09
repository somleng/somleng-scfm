class AddSomlengApiHostAndSomlengApiBaseUrlToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column(:accounts, :somleng_api_host, :string)
    add_column(:accounts, :somleng_api_base_url, :string)
  end
end
