DashboardUser = function () {

  pumiSelectize = new PumiSelectize('.js-pumi-selectize');

  this.init = function () {
    pumiSelectize.init();
  };
};

$(document).on('turbolinks:load', function () {
  if ((page.controller() !== 'users') || (page.action() !== 'edit')) {
    return;
  }

  dashboardUser = new DashboardUser();
  dashboardUser.init();
});
