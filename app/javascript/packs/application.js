// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import Coloris from "@melloware/coloris";
// import "channels"
import "trix"
import "@rails/actiontext"
import "../config.js.erb";

Rails.start()
Turbolinks.start()

import { singleFileUpload, multipleFileUpload } from 'fileUpload'
import "controllers"

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#clr-picker')){
    document.querySelector('#clr-picker').remove();
  }

  Coloris.init();
  Coloris({
    theme: 'dark',
    // el: 'input.color-picker',
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
