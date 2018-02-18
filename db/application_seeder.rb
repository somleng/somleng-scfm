class ApplicationSeeder
  OUTPUTS = {
    all: "all",
    none: "none",
    super_admin: "super_admin"
  }.freeze

  FORMATS = {
    human: "human",
    http_basic: "http_basic"
  }.freeze

  DEFAULT_OUTPUT = :none
  DEFAULT_FORMAT = :human

  def initialize(options = {}); end

  def seed!
    return unless create_super_admin_account?
    super_admin_account = create_super_admin_account!
    print_account_info(super_admin_account, "Super Admin") if output_super_admin?
  end

  private

  def create_super_admin_account?
    ENV["CREATE_SUPER_ADMIN_ACCOUNT"].to_i == 1
  end

  def output
    @output ||= OUTPUTS[default_output]
  end

  def format
    @format ||= FORMATS[default_format]
  end

  def default_output
    (ENV["OUTPUT"]&.to_sym) || DEFAULT_OUTPUT
  end

  def default_format
    (ENV["FORMAT"]&.to_sym) || DEFAULT_FORMAT
  end

  def create_super_admin_account!
    permissions = [:super_admin]

    account = Account.with_permissions(*permissions).first_or_initialize

    if account.new_record?
      account.permissions = permissions
      account.save!
    end

    account.access_tokens.first_or_create!(created_by: account)

    account
  end

  def output_all?
    output == OUTPUTS[:all]
  end

  def output_super_admin?
    output == OUTPUTS[:super_admin] || output_all?
  end

  def format_http_basic?
    format == FORMATS[:http_basic]
  end

  def print_account_info(account, type)
    access_token = account.access_tokens.first.token
    output = format_http_basic? ? access_token : "#{type} Account Access Token: #{access_token}\n"
    print(output)
  end
end
