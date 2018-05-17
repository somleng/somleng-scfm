$(document).on('turbolinks:load', function () {
  if ((page.controller() !== 'user_invitations') || (page.action() !== 'new')) {
    return;
  }

  dashboardUser = new DashboardUser();
  dashboardUser.init();
});
