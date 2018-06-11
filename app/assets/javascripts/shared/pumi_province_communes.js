PumiProvinceCommunes = function () {

  _this = this;
  _this.$province = $('.js-select-province');
  _this.$communes = $('.js-select-communes');
  _this.districts = [];
  _this.communes = [];
  _this.communeIds = _this.$communes.data('defaultValue') || [];
  _this.provinceId = _this.$province.data('defaultValue');

  initSelectProvince = function () {
    _this.$province.selectize({
      valueField: 'id',
      preload: true,
      searchField: ['name_en', 'name_km'],
      render: {
        item: renderItem,
        option: renderOption,
      },
      load: loadProvinces,
      onChange: getdistrictsCommunes,
    });

    _this.provincetize = _this.$province[0].selectize;
  };

  loadProvinces = function (query, callback) {
    $.when(
      $.getJSON(_this.$province.data('provinceUrl'), function (data) {
        callback(data);
      })
    ).done(function () {
      if (_this.provinceId) {
        _this.provincetize.setValue(_this.provinceId);
        _this.provinceId = null;
      }
    });
  };

  initSelectCommunes = function () {
    _this.$communes.selectize({
      options: [],
      optgroups: [],
      valueField: 'id',
      optgroupField: 'district_id',
      optgroupValueField: 'id',
      searchField: ['name_en', 'name_km'],
      closeAfterSelect: true,
      render: {
        optgroup_header: renderOptGroupHeader,
        item: renderItem,
        option: renderOption,
      },
      onChange: updateCommuneIds,
    });

    _this.communestize = _this.$communes[0].selectize;
  };

  updateCommuneIds = function (value) {
    newValue = [];
    $.when(
      $.map(value, function (value, index) {
        $.each(value.split(','), function (index, val) {
          newValue.push(val);
        });
      })
    ).done(function (data) {
      comparation = $(value).not(newValue).length === 0 && $(newValue).not(value).length === 0;
      if (!comparation) {
        _this.communestize.setValue(newValue);
      }
    });
  };

  renderOptGroupHeader = function (item, escape) {
    return '<div data-selectable data-value="' +
      escape(item.commune_ids) + '" class="optgroup-header">' +
      escape(item.name_en) + ' <span class="khmer">&nbsp;' +
      escape(item.name_km) + '</span></div>';
  };

  renderItem = function (item, escape) {
    return '<div>' + (item.name_en ? '<span class="english">' +
      escape(item.name_en) + '&nbsp;</span>' : '') +
      (item.name_km ? '<span class="khmer">' + escape(item.name_km) +
      '</span>' : '') + '</div>';
  };

  renderOption = function (item, escape) {
    var label = item.name_en;
    var caption = item.name_km;
    return '<div>' +
        '<span class="label">' + escape(label) + '</span></br>' +
        (caption ? '<span class="caption">' + escape(caption) + '</span>' : '') +
    '</div>';
  };

  getdistrictsCommunes = function (provinceId) {
    params = '?province_id=' + provinceId;
    districtUrl = _this.$province.data('pumiDistrictCollectionUrl') + params;
    communeUrl = _this.$province.data('pumiCommuneCollectionUrl') + params;

    request = $.getJSON(districtUrl);
    chained = request.then(function (data) {
      _this.districts = data;
      return $.getJSON(communeUrl);
    });

    chained.done(function (data) {
      _this.communes = data;
      _this.communestize.clearOptions();
      _this.communestize.clearOptionGroups();
      $.when(
        mapDistrictCommune()
      ).then(function () {
        $.each(_this.districts, function (index, district) {
          _this.communestize.addOptionGroup(district.id, district);
        });

        _this.communestize.addOption(_this.communes);
      }).done(function () {
        if (_this.communeIds.length) {
          _this.communestize.setValue(_this.communeIds);
          _this.communeIds = [];
        }
      });
    });
  };

  mapDistrictCommune = function () {
    $.each(_this.districts, function (index, district) {
      $.when(
        district.commune_ids = $.map(_this.communes, function (commune, index) {
          if (commune.id.slice(0, 4) === district.id) {
            commune.district_id = district.id;
            return commune.id;
          }
        })
      ).done(function (data) {
        _this.communes.push({
          district: true, name_en: district.name_en,
          id: district.commune_ids, district_id: district.id,
        });
      });
    });

    return _this.districts;
  };

  this.init = function () {
    initSelectCommunes();
    initSelectProvince();
  };
};
