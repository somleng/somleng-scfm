DashboardContact = function() {

  singleSelect2 = function() {
    $('.js-basic-select').select2().on('change', function(){
      $('input#'+$(this).attr('id')).val($(this).val());
    });
  }

  this.init = function() {
    singleSelect2();
  }
}

$(document).on('turbolinks:load', function() {
  if ((page.controller() !== 'contacts')) {
    return;
  }

  dashboardContact = new DashboardContact();
  dashboardContact.init();
});
