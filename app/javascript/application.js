// Entry point for the build script in your package.json

import "@hotwired/turbo-rails"
import '@fortawesome/fontawesome-free/js/all'
import * as bootstrap from "bootstrap"
import * as coreui from '@coreui/coreui';
require("@rails/activestorage").start()
import moment from "moment";

import jquery from 'jquery'
window.jQuery = jquery
window.$ = jquery

require("@nathanvda/cocoon")

document.addEventListener("turbo:load", function() {
    [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]')).map(function (element) {
      return new bootstrap.Tooltip(element)
    });

    [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]')).map(function (element) {
      return new bootstrap.Popover(element)
    });

    [].slice.call(document.querySelectorAll('[data-coreui="navigation"]')).map(function (element) {
      return coreui.Navigation.getOrCreateInstance(element);
    });

    [].slice.call(document.querySelectorAll('time[data-behavior~=local-time]')).map(function (element) {
      element.textContent = moment(element.textContent).format("lll (Z)")
    });

    [].slice.call(document.querySelectorAll('.sidebar')).map(function (element) {
      return coreui.Sidebar.getOrCreateInstance(element);
    });
  });
