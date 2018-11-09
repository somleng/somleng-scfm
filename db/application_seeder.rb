class ApplicationSeeder
  def seed!
    permissions = [:super_admin]

    account = Account.with_permissions(*permissions).first_or_initialize

    if account.new_record?
      account.permissions = permissions
      account.save!
    end

    account.access_tokens.first_or_create!(created_by: account)
  end
end
