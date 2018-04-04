DashboardCallout = function() {

  dashboardMetadataField = new DashboardMetadataField();

  this.init = function() {
    dashboardMetadataField.init();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'callouts')) {
    return;
  }

  dashboardCallout = new DashboardCallout();
  dashboardCallout.init();
});
