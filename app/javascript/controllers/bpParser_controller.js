import { Controller } from 'stimulus'
import DspBpParser from 'dsp-bp-parser';
import items from '../data/gameEntities.json';
import recipes from '../data/gameRecipes.json';

const images = require.context('../../assets/images/game_icons', true);
const imagePath = name => images(name, true);

export default class extends Controller {
  static targets = ['value']

  connect() {
    if (this.valueTarget.value.length !== 0) {
      this.parse();
    }
  }

  parse() {
    // 700000 is an semi-arbitrarily big string bytesize that should hit blueprints with more than 20-30k structures
    if (this.valueTarget.value.length <= 700000) {
      const data = new DspBpParser(this.valueTarget.value)
      this.renderPreview(data);
    } else {
      this.renderSizeWarning(this.valueTarget.value.length);
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

  renderPreview(data) {
    if (document.querySelector('.t-blueprint__requirements-preview')) {
      document.querySelector('.t-blueprint__requirements-preview').remove();
    }

    if ('content' in document.createElement('template')) {
      const bpElement = document.querySelector('.m-form__important');
      const bpRequirementsTemplate = document.querySelector('#bp-requirements');
      const bpEntityTemplate = document.querySelector('#bp-entity');
      const bpEntityRecipesTemplate = document.querySelector('#bp-entity-recipes');
      const bpEntityRecipeTemplate = document.querySelector('#bp-entity-recipe');
      const bpEntityParamsTemplate = document.querySelector('#bp-entity-params');
      const bpEntityParamTemplate = document.querySelector('#bp-entity-param');

      // Total structure
      let bpReq = bpRequirementsTemplate.content.cloneNode(true);
      bpReq.querySelector("#totalStructure").textContent = data.summary.totalStructure;
      bpElement.append(bpReq);

      // Item list
      const bpEntityList = document.querySelector('#bp-entity-list');

      // Building
      for (const [itemId, _] of Object.entries(data.summary.buildings)) {
        let bpEnt = bpEntityTemplate.content.cloneNode(true);
        let bpEntRecipes = bpEntityRecipesTemplate.content.cloneNode(true);
        let image = this.createImageElement(imagePath(`./entities/${itemId}.png`));

        // [Building] Assign image
        const entityImageEl = bpEnt.querySelector("#entity-image");
        entityImageEl.appendChild(image);

        // [Building] Assign tooltip
        this.createTooltip(entityImageEl, items[itemId]);

        // [Building] Assign count
        bpEnt.querySelector("#entity-tally").textContent = data.summary.buildings[itemId].count;

        // BuildingRecipe
        for (const [recipeId, count] of Object.entries(data.summary.buildings[itemId].recipeIds)) {
          let bpEntRecipe = bpEntityRecipeTemplate.content.cloneNode(true);
          let image = this.createImageElement(imagePath(`./recipes/${recipeId}.png`));

          // [BuildingRecipe] Assign image
          const entityRecipeImageEl = bpEntRecipe.querySelector('#entity-recipe-image')
          entityRecipeImageEl.appendChild(image);

          // [BuildingRecipe] Assign tooltip
          this.createTooltip(entityRecipeImageEl, recipes[recipeId]);

          // [BuildingRecipe] Assign count
          bpEntRecipe.querySelector('#entity-recipe-tally').textContent = count;

          bpEntRecipes.querySelector('.t-blueprint__requirements-entity__recipes').appendChild(bpEntRecipe);
        }
        bpEnt.appendChild(bpEntRecipes);

        // StationItem
        data.summary.buildings[itemId].parameters.forEach(param => {
          if (param.hasOwnProperty('itemCount')) {
            let bpEntParams = bpEntityParamsTemplate.content.cloneNode(true);

            param.itemSettings.forEach(p => {
              if (p.itemId === 0) { return; }

              let bpEntParam = bpEntityParamTemplate.content.cloneNode(true);
              let image = this.createImageElement(imagePath(`./entities/${p.itemId}.png`));

              // [StationItem] Assign image
              const entityRecipeImageEl =
              bpEntParam.querySelector("#entity-recipe-image").appendChild(image);

              // [StationItem] Assign tooltip
              this.createTooltip(entityRecipeImageEl, items[p.itemId]);

              // [StationItem] Assign label
              bpEntParam.querySelector('#entity-param-local').textContent = `Local: ${this.convertLogicLabel(p.localLogic)}`;
              bpEntParam.querySelector('#entity-param-remote').textContent = `Remote: ${this.convertLogicLabel(p.remoteLogic)}`;
              bpEntParam.querySelector('#entity-param-max').textContent = `Max: ${p.max}`;

              bpEntParams.querySelector('.t-blueprint__requirements-entity__params').appendChild(bpEntParam);
            })

            bpEnt.appendChild(bpEntParams);
          }
        })
        bpEntityList.appendChild(bpEnt);
      }

      // Inserter
      this.createItem(bpEntityTemplate, bpEntityList, data.summary.inserters)

      // Belt
      this.createItem(bpEntityTemplate, bpEntityList, data.summary.belts)
    }
  }

  convertLogicLabel(value) {
    switch (value) {
      case 0:
        return 'Supply';
      case 1:
        return 'Demand';
      case 2:
        return 'Storage';
    }
  }

  createImageElement(path) {
    let imgElement = document.createElement('img');
    imgElement.src = path;

    return imgElement;
  }

  createItem(entTpl, entList, data) {
    for (const [itemId, count] of Object.entries(data)) {
      if (count === 0) { continue; }

      let bpEnt = entTpl.content.cloneNode(true);
      let image = this.createImageElement(imagePath(`./entities/${itemId}.png`));

      // Assign image
      const entityImageEl = bpEnt.querySelector("#entity-image");
      entityImageEl.appendChild(image);

      // Assign tooltip
      this.createTooltip(entityImageEl, items[itemId]);

      // Assign count
      bpEnt.querySelector("#entity-tally").textContent = count;

      entList.appendChild(bpEnt);
    }
  }

  createTooltip(el, name) {
    el.classList.add('tooltip-trigger');
    el.dataset.controller = 'tooltip';
    el.dataset.tippyContent = name;
    el.dataset.tippyPlacement = 'bottom';
  }
}
