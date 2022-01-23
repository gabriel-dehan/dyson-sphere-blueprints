import { Controller } from 'stimulus'
// import DspBpParser from 'dsp-bp-parser';
// import items from '../data/gameEntities.json';
// import recipes from '../data/gameRecipes.json';

// const images = require.context('../../assets/images/game_icons', true);
// const imagePath = name => images(name, true);

export default class extends Controller {
  static targets = ['value']

  connect() {
    if (this.valueTarget.value.length !== 0) {
      this.parse();
    }
  }

  parse() {
    if (this.valueTarget.value.length <= 1000000) {
      // const data = new DspBpParser(this.valueTarget.value)
      // this.renderPreview(data);
    } else {
      this.renderSizeWarning(this.valueTarget.value.length);
    }
  }
}
