import { Controller } from "stimulus"
import Preview3DRenderer from 'brokenmass3dpreview';
import Entities from '../data/gameEntities.json';
import Recipes from '../data/gameRecipes.json';

const assetPathResolver = (assetType, id) => {
  // Faster loading for textures
  const extension = assetType === 'textures' ? 'jpg' : 'png';
  return `${window._cdnURL}/public/game_icons/${assetType}/${id}.${extension}`;
}
export default class extends Controller {
  static targets = [ "data", "output", "tooltip", "loader", "action" ]

  render() {
    const tooltipContainer = this.tooltipTarget;
    const container = this.outputTarget;
    const data = this.dataTarget.value;
    const actionButton = this.actionTarget;

    const dataSplitOnName = data.split(':');
    const strippedData = dataSplitOnName.length > 1 ? dataSplitOnName[1] : data;

    // Only render if output is empty (hasn't been rendered yet)
    if (!container.childNodes.length) {
      this.renderer = new Preview3DRenderer({
        tooltipContainer,
        container,
        data: strippedData,
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

      this.renderer.on('render:start', () => {
        this.loaderTarget.classList.remove('hidden');
      });

      this.renderer.on('assets:loader:complete', () => {
        // Add a few hundred milliseconds to smooth out the transition
        setTimeout(() => this.loaderTarget.classList.add('hidden'), 500);
      });

      this.renderer.on('entity:select', (data) => {
        // console.log('Select', data);
      });

      this.renderer.render();

      // Pause the renderer on tab out if the browser supports it
      if (typeof document.hidden !== "undefined") {
        document.addEventListener('visibilitychange', () => {
          if (document.hidden || document.visibilityState === 'hidden') {
            this.renderer.pause();
          } else {
            this.renderer.restart();
          }
        });
      }

      actionButton.addEventListener('click', (e) => {
        e.preventDefault();
        if (this.renderer.beltMovement) {
          this.renderer.setBeltMovement(false);
          actionButton.textContent = 'Animate';
        } else {
          this.renderer.setBeltMovement(true);
          actionButton.textContent = 'Stop animation';
        }
      })
    }
  }
}
