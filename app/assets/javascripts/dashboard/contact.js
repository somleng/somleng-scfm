DashboardContact = function () {
  provinceCss = '.js-province-selectize';
  districtCss = '.js-district-selectize';
  communeCss = '.js-cummune-selectize';

  onParentChange = function (child, parent) {
    $(parent).on('change', function (value) {
      var url = $(child).data('pumiUrl').replace('FILTER', this.value);
      loadData(child, url);
    });
  };

  this.init = function () {
    province = new PumiSelectize(provinceCss);
    province.init();

    district = new PumiSelectize(districtCss);
    district.init();
    onParentChange(districtCss, provinceCss);

    commune = new PumiSelectize(communeCss);
    commune.init();
    onParentChange(communeCss, districtCss);
  };
};

$(document).on('turbolinks:load', function () {
  actions = ['new', 'create', 'edit', 'update'];
  if ((page.controller() !== 'contacts') || !actions.includes(page.action())) {
    return;
  }

  dashboardUser = new DashboardContact();
  dashboardUser.init();
});
