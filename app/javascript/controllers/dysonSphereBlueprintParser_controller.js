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
      // this.renderSizeWarning(this.valueTarget.value.length);
    }
  }

  renderSizeWarning(size) {
    if (document.querySelector('.t-blueprint__requirements-preview')) {
      document.querySelector('.t-blueprint__requirements-preview').remove();
    }

    if ('content' in document.createElement('template')) {
      // Customize message based on size, needs improvements, this is just quick and dirty
      let sizeHumanizedCounter = 'quite big';
      if (size >= 1000000) {
        sizeHumanizedCounter = 'too big';
      }

      const bpElement = document.querySelector('.m-form__important');
      const bpSizeWarningTemplate = document.querySelector('#bp-size-warning');
      let bpWarning = bpSizeWarningTemplate.content.cloneNode(true);
      bpWarning.querySelector("#blueprint-sizeWarning-humanizedCounter").textContent = sizeHumanizedCounter;
      bpElement.append(bpWarning);
    }
  }
}
