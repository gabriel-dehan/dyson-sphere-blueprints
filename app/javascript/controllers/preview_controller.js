import { Controller } from "stimulus"
import Preview3DRenderer from 'brokenmass3dpreview';
import Entities from '../data/gameEntities.json';
import Recipes from '../data/gameRecipes.json';

const assetPathResolver = (assetType, id) => {
  return `${window._cdnURL}/public/game_icons/${assetType}/${id}.png`;
}
export default class extends Controller {
  static targets = [ "data", "output", "tooltip", "loader" ]

  render() {
    const tooltipContainer = this.tooltipTarget;
    const container = this.outputTarget;
    const data = this.dataTarget.value;

    // Only render if output is empty (hasn't been rendered yet)
    if (!container.childNodes.length) {
      const renderer = new Preview3DRenderer({
        tooltipContainer,
        container,
        data,
        setTooltipContent: (data) => {
          const { protoId, recipeId } = data;
          const entityName = Entities[protoId];
          // If we don't find the entity name we probably don't have an icon for it (modded entity)
          const entityIconId = entityName ? protoId : 'default';

          const entityHtml = `
            <span class="o-preview-tooltip__entity">
              <img src="${assetPathResolver('entities', entityIconId)}" />
              <h4>${entityName || 'Unknown'}</h4>
            </span>`;


          let recipeHtml = '';

          if (recipeId && recipeId > 0) {
            recipeHtml = `
              <span class="o-preview-tooltip__recipe">
                <img src="${assetPathResolver('recipes', recipeId === 0 ? 'default' : recipeId )}" />
                <h4>Recipe: ${Recipes[recipeId]}</h4>
              </span>`;
          }

          return `
            <span class="o-preview-tooltip__content">
              ${entityHtml}
              ${recipeHtml}
            </span>
          `;
        },
        assetPathResolver,
      });

      renderer.on('render:start', () => {
        this.loaderTarget.classList.remove('hidden');
      })

      renderer.on('render:complete', () => {
        this.loaderTarget.classList.add('hidden');
      })

      renderer.on('entity:select', (data) => {
        // console.log('Select', data);
      })

      renderer.render();
    }
  }
}
