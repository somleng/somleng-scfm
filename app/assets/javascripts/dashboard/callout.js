DashboardCallout = function () {
  _this = this;
  _this.provinceCss = '.js-select-province';
  _this.$districtsCommunes = $('#districts-communes');
  _this.firstLoad = true;

  province = new PumiSelectize(_this.provinceCss);

  onProvinceChange = function () {
    $(_this.provinceCss).on('change', function () {
      params = '?province_id=' + this.value;
      districtUrl = $(this).data('pumiDistrictCollectionUrl') + params;
      communeUrl = $(this).data('pumiCommuneCollectionUrl') + params;
      communeIds = $(this).data('defaultCommuneIds');

      getDistricts = $.getJSON(districtUrl);
      getCommunes = $.getJSON(communeUrl);
      getDistricts.then(function (districts) {
        buildDistricts(districts);
      }).done(function () {
        getCommunes.then(function (communes) {
          buildCommunes(communes);
        }).done(function () {
          if (_this.firstLoad) {
            checkeCommunes(communeIds);
            _this.firstLoad = false;
          }
        });
      });
    });
  };

  checkeCommunes = function (communeIds) {
    $.each(communeIds, function (index, communeId) {
      $('#callout_commune_' + communeId).prop('checked', true);
      findDistrictOf(communeId.slice(0, 4)).prop('checked', true);
    });
  };

  buildDistricts = function (districts) {
    _this.$districtsCommunes.html('');
    $.each(districts, function (index, district) {
      _this.$districtsCommunes.append(pumiCheckbox('district', district));
    });
  };

  buildCommunes = function (communes) {
    $.each(communes, function (index, commune) {
      $parent = findDistrictOf(commune.id.slice(0, 4)).parent();
      $parent.append(pumiCheckbox('commune', commune));
    });
  };

  pumiCheckbox = function (type, object) {
    return '<div class="form-check">' +
    '<input class="form-check-input ' + type + '-ids" type="checkbox" ' +
    'value=' + object.id + ' name="callout[' + type + '_ids][]" ' +
    'id="callout_' + type + '_' + object.id + '">' +
    '<label class="string optional form-check-label"' +
    'for="callout_' + type + '_' + object.id + '">'
    + object.name_km + '&nbsp;' + object.name_en + '</label></div>';
  };

  onCheckAll = function () {
    $('body').on('change', '#check_all', function () {
      $children = _this.$districtsCommunes.find('.form-check-input');
      if ($(this).is(':checked')) {
        $children.prop('checked', true);
      } else {
        $children.prop('checked', false);
      }
    });
  };

  onCheckDistrict = function () {
    $('body').on('change', '.district-ids', function () {
      $children = $(this).parent().find('.commune-ids');
      if ($(this).is(':checked')) {
        $children.prop('checked', true);
      } else {
        $children.prop('checked', false);
      }
    });
  };

  onCommuneCheckboxChange = function () {
    _this.$districtsCommunes.on('change', '.commune-ids', function () {
      var $district = findDistrictOf($(this).val());

      if ($(this).is(':checked')) {
        $district.prop('checked', true);
      } else {
        $('#check_all').prop('checked', false);
        if ($district.parent().find('.commune-ids:checked').length == 0) {
          $district.prop('checked', false);
        }
      }
    });
  };

  findDistrictOf = function (communeId) {
    return $('#callout_district_' + communeId.slice(0, 4));
  };

  this.init = function () {
    province.init();
    onProvinceChange();
    onCheckAll();
    onCheckDistrict();
    onCommuneCheckboxChange();
  };
};

$(document).on('turbolinks:load', function () {
  actions = ['new', 'create', 'edit', 'update'];
  if ((page.controller() !== 'callouts') || !actions.includes(page.action())) {
    return;
  }

  dashboardCallout = new DashboardCallout();
  dashboardCallout.init();
});
