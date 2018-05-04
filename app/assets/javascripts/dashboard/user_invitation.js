DashboardUserInvitation = function() {

  multiSelect2 = function() {
    $('.js-basic-multiple-select').select2();
  }

  this.init = function() {
    multiSelect2();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'user_invitations')) {
    return;
  }

  dashboardUserInvitation = new DashboardUserInvitation();
  dashboardUserInvitation.init();
});
