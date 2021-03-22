import { Controller } from "stimulus"
import Tagify from '@yaireo/tagify'
import GameEntities from '../data/gameEntities.json';
import GameTags from '../data/additionalTags.json';

export default class extends Controller {
  static targets = [ "input" ]

  initialize() {
    this.whitelist = [...Object.keys(GameTags), ...Object.values(GameEntities)]
  }

  connect() {
    const tagify = new Tagify(
      this.inputTarget, {
        placeholder: "Search for a tag: mall, oil refinery, fractionator...",
        whitelist: this.whitelist,
        enforceWhitelist: true,
        editTags: false,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
      }
    );
  }
}
