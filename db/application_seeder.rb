class ApplicationSeeder
  def initialize(options = {})
  end

  def seed!
    create_super_admin_account!
  end

  private

  def create_super_admin_account!
    permissions = [:super_admin]

    account = Account.with_permissions(*permissions).first_or_initialize

    if account.new_record?
      account.permissions = permissions
      account.save!
    end

    account
  end
end

