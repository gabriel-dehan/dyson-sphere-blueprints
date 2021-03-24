import { Controller } from "stimulus"
import Preview3DRenderer from '../blueprintEditor/3D/renderer';

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
    });

    renderer.render();
  }
}
