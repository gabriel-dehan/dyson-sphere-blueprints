// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
// import "channels"
import "../coloris.js"
import "trix"
import "@rails/actiontext"
import "../config.js.erb";

Rails.start()
Turbolinks.start()

import { singleFileUpload, multipleFileUpload } from 'fileUpload'
import "controllers"

document.addEventListener('turbolinks:load', () => {
  Coloris({
    theme: 'dark',
    focusInput: false,
  });

  document.querySelectorAll('input[type=file]').forEach(fileInput => {
    if (fileInput.multiple) {
      multipleFileUpload(fileInput)
    } else {
      singleFileUpload(fileInput)
    }
  })
});
