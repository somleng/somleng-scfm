DashboardUserInvitation = function () {

  pumiSelectize = new PumiSelectize();

  this.init = function () {
    pumiSelectize.init();
  };
};

$(document).on('turbolinks:load', function () {
  if ((page.controller() !== 'user_invitations')) {
    return;
  }

  dashboardUserInvitation = new DashboardUserInvitation();
  dashboardUserInvitation.init();
});
