DashboardUser = function() {

  singleSelect2 = function() {
    $('.js-basic-multiple-select').select2();
  }

  this.init = function() {
    singleSelect2();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'users')) {
    return;
  }

  dashboardUser = new DashboardUser();
  dashboardUser.init();
});
