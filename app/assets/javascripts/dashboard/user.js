DashboardUser = function () {

  pumiSelectize = new PumiSelectize();

  this.init = function () {
    pumiSelectize.init();
  };
};

$(document).on('turbolinks:load', function () {
  if ((page.controller() !== 'users')) {
    return;
  }

  dashboardUser = new DashboardUser();
  dashboardUser.init();
});
