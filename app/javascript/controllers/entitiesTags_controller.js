// Visit The Stimulus Handbook for more details
// https://stimulusjs.org/handbook/introduction
//
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"
import Tagify from '@yaireo/tagify'
import GameEntities from '../data/gameEntities.json';

export default class extends Controller {
  static targets = [ "input" ]

  initialize() {
    this.whitelist = ["Mall", ...Object.values(GameEntities)]
  }

  connect() {
    const tagify = new Tagify(
      this.inputTarget, {
        placeholder: "Enter a tag: iron ingot, x-ray cracking, fractionator...",
        whitelist: this.whitelist,
        enforceWhitelist: true,
        editTags: false,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
      }
    );
  }
}
