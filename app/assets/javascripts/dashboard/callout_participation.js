DashboardCalloutParticipation = function() {

  singleSelect2 = new SingleSelect2();

  this.init = function() {
    singleSelect2.init();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'callout_participations')) {
    return;
  }

  dashboardCalloutParticipation = new DashboardCalloutParticipation();
  dashboardCalloutParticipation.init();
});
