PumiSelectize = function (element) {
  filteredProvinceIds = $(element).data('filterProvinceIds');

  loadData = function (selector, url) {
    $.when(
      $.getJSON(url, function (data) {
        var provinces = data;

        if (filteredProvinceIds) {
          provinces = $.grep(data, function (province, index) {
            return ($.inArray(province.id, filteredProvinceIds) >= 0);
          });
        }

        $(selector)[0].selectize.clearOptions();
        $(selector)[0].selectize.addOption(provinces);
      })
    ).done(function (data) {
      if ($(selector).data('defaultValue') && data.length) {
        $(selector)[0].selectize.setValue($(selector).data('defaultValue'));
        $(selector).data('defaultValue', null);
      }
    });
  };

  initSelect = function () {
    $(element).selectize({
      valueField: 'id',
      searchField: ['name_en', 'name_km'],
      closeAfterSelect: false,
      render: {
        item: renderItem,
        option: renderOption,
      },
    });

    loadData(element, $(element).data('pumiUrl'));
  };

  renderItem = function (item, escape) {
    return '<div>' + (item.name_km ? '<span class="khmer">' +
      escape(item.name_km) + '&nbsp;</span>' : '') +
      (item.name_en ? '<span class="english">' + escape(item.name_en) +
      '</span>' : '') + '</div>';
  };

  renderOption = function (item, escape) {
    var label = item.name_km;
    var caption = item.name_en;
    return '<div>' +
        '<span class="label">' + escape(label) + '</span></br>' +
        (caption ? '<span class="caption">' + escape(caption) + '</span>' : '') +
    '</div>';
  };

  this.init = function () {
    initSelect();
  };
};
