import { Controller } from "stimulus"
import Preview3DRenderer from 'brokenmass3dpreview';

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
        return `<p>originalId  ${data.originalId}</p>
         <p>modelIndex: ${data.modelIndex}</p>
         <p>recipeId:   ${data.recipeId}</p>`;
      },
      assetPathResolver: (assetType, id) => {
        return `https://dyson-sphere-blueprints-dev.s3-eu-west-1.amazonaws.com/public/game_icons/${assetType}/${id}.png`;
      },
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
