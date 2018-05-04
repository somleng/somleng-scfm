DashboardUser = function() {

  multiSelect2 = function() {
    $('.js-basic-multiple-select').select2();
  }

  this.init = function() {
    multiSelect2();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'users')) {
    return;
  }

  dashboardUser = new DashboardUser();
  dashboardUser.init();
});
