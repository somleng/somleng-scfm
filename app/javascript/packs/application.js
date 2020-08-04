require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()

import "bootstrap";
import "@fortawesome/fontawesome-free/js/all";
import moment from "moment";

import "../components/direct_upload";
import "../stylesheets/application";

document.addEventListener("turbolinks:load", function() {
  $('time[data-behavior~=local-time]').each(function() {
    $(this).text(
      moment($(this).text()).format("lll (Z)")
    )
  })
});
