class Dashboard::AdminController < Dashboard::BaseController
  before_action :authorize_admin!
end
