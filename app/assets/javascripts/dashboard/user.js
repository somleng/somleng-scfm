$(document).on('turbolinks:load', function () {
  if ((page.controller() !== 'users') || (page.action() !== 'edit')) {
    return;
  }

  pumiSelectize = new PumiSelectize('.js-pumi-selectize');
  pumiSelectize.init();
});
