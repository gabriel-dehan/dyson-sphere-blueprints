// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "trix"
import "@rails/actiontext"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// External imports
document.addEventListener('dnd-upload:initialize', (e) => {
  const errorNode = e.target.parentNode.parentNode.querySelector('.error');
  errorNode.textContent = '';
});

document.addEventListener('dnd-upload:error', (e) => {
  e.preventDefault();
  const errorNode = e.target.parentNode.parentNode.querySelector('.error');
  errorNode.textContent = e.detail.error;
});

// Internal imports, e.g:
document.addEventListener('turbolinks:load', () => {
  // Call your functions here
});

import "controllers"

require("trix")
require("@rails/actiontext")