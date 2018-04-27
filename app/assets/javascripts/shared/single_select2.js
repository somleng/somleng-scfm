SingleSelect2 = function() {
  var prepareSelect2 = function() {
    $('.js-select2').select2({
      placeholder: 'Select a contact',
      ajax: {
        delay: 250,
        url: $(this).data('ajax-url'),
        dataType: 'json',
        data:  function (params) {
          return {
            q: params.term,
            page: params.page
          };
        },
        processResults: function (data) {
          var data = $.map(data, function (obj) {
            obj.text = obj.text || obj.msisdn;
            return obj;
          });

          return {
            results: data,
            "pagination": {
              "more": (data.length == 25)
            }
          };
        }
      }
    });
  }

  this.init = function() {
    prepareSelect2();
  }
}
