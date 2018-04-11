DashboardUserInvitation = function() {

  chosenSelect = new ChosenSelect();

  this.init = function() {
    chosenSelect.init();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'user_invitations')) {
    return;
  }

  dashboardUserInvitation = new DashboardUserInvitation();
  dashboardUserInvitation.init();
});
