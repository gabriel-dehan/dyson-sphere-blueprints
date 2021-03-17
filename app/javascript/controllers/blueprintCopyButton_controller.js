import ClipboardJS from 'clipboard';
import { Controller } from "stimulus"
import tippy from 'tippy.js';

export default class extends Controller {
  static targets = [ "copy" ]

  connect() {
    this.clipboard = new ClipboardJS(this.copyTarget);

    this.clipboard.on('success', (e) => {
      const tooltip = tippy(e.trigger, {
        content: 'Copied !',
        trigger: "manual",
        duration: 200,
        onHidden: instance => instance.destroy(),
      });

      tooltip.show();

      setTimeout(() => {
        tooltip.hide();
      }, 800);

    });
  }

  disconnect() {
    this.clipboard.destroy();
  }
}
