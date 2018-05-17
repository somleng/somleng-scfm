PumiSelectize = function (element) {
  _this = this;
  _this.$selectizer = $(element);
  _this.defaultValue = _this.$selectizer.data('defaultValue');
  _this.dataUrl = _this.$selectizer.data('pumiUrl');
  _this.preload = _this.$selectizer.data('preload');

  initSelect = function () {
    _this.$selectizer.selectize({
      valueField: 'id',
      searchField: ['name_en', 'name_km'],
      preload: true,
      closeAfterSelect: true,
      render: {
        item: renderItem,
        option: renderOption,
      },
      load: loadData,
    });

    _this.selectizer = _this.$selectizer[0].selectize;
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

  loadData = function (query, callback) {
    $.when(
      $.getJSON(_this.dataUrl, function (data) {
        callback(data);
      })
    ).done(function (data) {
      if (_this.defaultValue && data.length) {
        _this.selectizer.setValue(_this.defaultValue);
        _this.defaultValue = null;
      }
    });
  };

  this.init = function () {
    initSelect();
  };
};
