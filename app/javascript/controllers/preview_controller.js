import { Controller } from "stimulus"
import Preview3DRenderer from 'brokenmass3dpreview';
import Entities from '../data/gameEntities.json';
import Recipes from '../data/gameRecipes.json';

const assetPathResolver = (assetType, id) => {
  if (railsAssetsHash == '') {
    return `${railsAssetsPath}/game_icons/${assetType}/${id}.png`;
  } else {
    return `${railsAssetsPath}/game_icons/${assetType}/${id}-${railsAssetsHash}.png`;
  }
}
export default class extends Controller {
  static targets = [ "data", "output", "tooltip" ]

  connect() {
    const tooltipContainer = this.tooltipTarget;
    const container = this.outputTarget;
    const data = this.dataTarget.value;

    const renderer = new Preview3DRenderer({
      tooltipContainer,
      container,
      data,
      setTooltipContent: (data) => {
        const { protoId, recipeId } = data;
        const entityHtml = `
          <span class="o-preview-tooltip__entity">
            <img src="${assetPathResolver('entities', protoId)}" />
            <h4>${Entities[protoId]}</h4>
          </span>`;
        const recipeHtml = `
          <span class="o-preview-tooltip__recipe">
            <img src="${assetPathResolver('recipes', recipeId === 0 ? 'default' : recipeId )}" />
            <h4>Recipe: ${Recipes[recipeId]}</h4>
          </span>`;

        return `
          <span class="o-preview-tooltip__content">
            ${entityHtml}
            ${recipeId ? recipeHtml : ''}
          </span>
        `;
      },
      assetPathResolver,
    });

    renderer.on('render:start', function() {
      console.log('Started');
    })

    renderer.on('render:complete', function() {
      console.log('Rendered');
    })

    renderer.on('entity:select', function(data) {
      console.log('Select', data);
    })


    renderer.render();
  }
}
