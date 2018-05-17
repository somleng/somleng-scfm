PumiSelectize = function (element) {
  loadData = function (selector, url) {
    $.when(
      $.getJSON(url, function (data) {
        $(selector)[0].selectize.clearOptions();
        $(selector)[0].selectize.addOption(data);
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
      closeAfterSelect: true,
      render: {
        item: renderItem,
        option: renderOption,
      },
    });

    loadData(element, $(element).data('pumiUrl'));
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

  this.init = function () {
    initSelect();
  };
};
