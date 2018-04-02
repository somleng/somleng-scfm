DashboardCallout = function() {

  dashboardBase = new DashboardBase();

  this.init = function() {
    dashboardBase.init();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'callouts')) {
    return;
  }

  dashboardCallout = new DashboardCallout();
  dashboardCallout.init();
});
