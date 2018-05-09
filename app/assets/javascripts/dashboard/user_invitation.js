DashboardUserInvitation = function () {

  pumiSelectize = new PumiSelectize('.js-pumi-selectize');

  this.init = function () {
    pumiSelectize.init();
  };
};

$(document).on('turbolinks:load', function () {
  if ((page.controller() !== 'user_invitations') || (page.action() !== 'new')) {
    return;
  }

  dashboardUserInvitation = new DashboardUserInvitation();
  dashboardUserInvitation.init();
});
