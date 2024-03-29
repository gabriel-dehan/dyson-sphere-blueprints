import ClipboardJS from 'clipboard';
import { Controller } from "stimulus"
import tippy from 'tippy.js';

export default class extends Controller {
  static targets = [ "copy" ]

  connect() {
    this.clipboard = new ClipboardJS(this.copyTarget, {
      text: () => {
        const dataAttribute = this.copyTarget.getAttribute('data-clipboard-text');
        if (dataAttribute) {
          return dataAttribute;
        } else {
          return document.querySelector('[data-clipboard-target="true"]').value;
        }
      }
    });

    this.copyTarget.addEventListener('click', (e) => e.preventDefault());

    this.clipboard.on('success', (e) => {
      const tooltip = tippy(e.trigger, {
        content: 'Copied !',
        trigger: "manual",
        duration: 200,
        onHidden: instance => instance.destroy(),
      });

      tooltip.show();
      this.usageTrackerController.track(null, this.element.dataset.blueprintId);

      setTimeout(() => {
        tooltip.hide();
      }, 800);

    });
  }

  disconnect() {
    this.clipboard.destroy();
    this.copyTarget.removeEventListener('click', (e) => e.preventDefault());
  }

  get usageTrackerController() {
    return this.application.getControllerForElementAndIdentifier(document.querySelector("[data-controller*='usageTracker']"), "usageTracker")
  }
}
