$(document).on('turbolinks:load', function () {
  if ((page.controller() !== 'user_invitations') || (page.action() !== 'new')) {
    return;
  }

  pumiSelectize = new PumiSelectize('.js-pumi-selectize');
  pumiSelectize.init();
});
