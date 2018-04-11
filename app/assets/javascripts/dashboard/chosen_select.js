ChosenSelect = function() {
  var initialChosenSelect = function() {
    $('.js-chosen-select').chosen({
      max_shown_results: 10,
      search_contains: true,
      display_selected_options: true
    });
  }

  this.init = function() {
    initialChosenSelect();
  }
}
