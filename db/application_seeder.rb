class ApplicationSeeder
  OUTPUTS = {
    :all => "all",
    :none => "none",
    :super_admin => "super_admin",
  }

  DEFAULT_OUTPUT = :none

  def initialize(options = {})
  end

  def seed!
    if create_super_admin_account?
      super_admin_account = create_super_admin_account!
      print_account_info(super_admin_account, "Super Admin") if output_super_admin?
    end
  end

  private

  def create_super_admin_account?
    ENV["CREATE_SUPER_ADMIN_ACCOUNT"].to_i == 1
  end

  def output
    @output ||= OUTPUTS[default_output]
  end

  def default_output
    (ENV["OUTPUT"] && ENV["OUTPUT"].to_sym) || DEFAULT_OUTPUT
  end

  def create_super_admin_account!
    permissions = [:super_admin]

    account = Account.with_permissions(*permissions).first_or_initialize

    if account.new_record?
      account.permissions = permissions
      account.save!
    end

    account.access_tokens.first_or_create!(:created_by => account)

    account
  end

  def output_all?
    output == OUTPUTS[:all]
  end

  def output_super_admin?
    output == OUTPUTS[:super_admin] || output_all?
  end

  def print_account_info(account, type)
    print(
      "#{type} Account Access Token: #{account.access_tokens.first.token}\n"
    )
  end
end

