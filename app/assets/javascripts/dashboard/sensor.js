$(document).on('turbolinks:load', function () {
  actions = ['new', 'create', 'edit', 'update'];
  if ((page.controller() !== 'sensors') || !actions.includes(page.action())) {
    return;
  }

  pumiSelectize = new PumiSelectize('.js-pumi-selectize');
  pumiSelectize.init();
});
