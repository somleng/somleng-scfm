class AddPermissionsToAccessTokens < ActiveRecord::Migration[5.2]
  def change
    add_column(
      :oauth_access_tokens,
      :permissions,
      :bigint,
      default: AccessToken::DEFAULT_PERMISSIONS_BITMASK,
      null: false
    )
  end
end
