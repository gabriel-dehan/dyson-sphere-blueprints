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
      width: container.clientWidth,
      height: container.clientHeight,
      setTooltipContent: (data) => {
        const { protoId, recipeId } = data;
        return `
          <span>
            <img src="${assetPathResolver('entities', protoId)}" />
            <h4>${Entities[protoId]}</h4>
          </span>
          <span>
            <img src="${assetPathResolver('recipes', recipeId)}" />
            <h4>Recipe: ${Recipes[recipeId]}</h4>
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
