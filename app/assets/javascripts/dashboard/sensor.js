$(document).on('turbolinks:load', function () {
  actions = ['new', 'create', 'edit', 'update'];
  if ((page.controller() !== 'sensors') || !actions.includes(page.action())) {
    return;
  }

  pumiProvinceCommunes = new PumiProvinceCommunes();
  pumiProvinceCommunes.init();
});
