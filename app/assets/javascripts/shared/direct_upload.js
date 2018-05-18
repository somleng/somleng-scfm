"use strict";

// direct_uploads.js

addEventListener("direct-upload:initialize", function (event) {
  var target = event.target;
  var detail = event.detail;
  var id = detail.id;
  var file = detail.file;

  target.insertAdjacentHTML("beforebegin", "\n    <div id=\"direct-upload-" + id + "\" class=\"direct-upload direct-upload--pending\">\n      <div id=\"direct-upload-progress-" + id + "\" class=\"direct-upload__progress\" style=\"width: 0%\"></div>\n      <span class=\"direct-upload__filename\">" + file.name + "</span>\n    </div>\n  ");
});

addEventListener("direct-upload:start", function (event) {
  var id = event.detail.id;

  var element = document.getElementById("direct-upload-" + id);
  element.classList.remove("direct-upload--pending");
});

addEventListener("direct-upload:progress", function (event) {
  var _event$detail = event.detail;
  var id = _event$detail.id;
  var progress = _event$detail.progress;

  var progressElement = document.getElementById("direct-upload-progress-" + id);
  progressElement.style.width = progress + "%";
});

addEventListener("direct-upload:error", function (event) {
  event.preventDefault();
  var _event$detail2 = event.detail;
  var id = _event$detail2.id;
  var error = _event$detail2.error;

  var element = document.getElementById("direct-upload-" + id);
  element.classList.add("direct-upload--error");
  element.setAttribute("title", error);
});

addEventListener("direct-upload:end", function (event) {
  var id = event.detail.id;

  var element = document.getElementById("direct-upload-" + id);
  element.classList.add("direct-upload--complete");
});
