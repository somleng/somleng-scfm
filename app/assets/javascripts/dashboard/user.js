DashboardUser = function() {

  chosenSelect = new ChosenSelect();

  this.init = function() {
    chosenSelect.init();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'users')) {
    return;
  }

  dashboardUser = new DashboardUser();
  dashboardUser.init();
});
