import { Controller } from "stimulus"
import tippy from 'tippy.js';

export default class extends Controller {
  static targets = [ "copy", "icon" ]

  connect() {
    this.copyTarget.addEventListener('click', async (e) => {
      e.preventDefault();
      const blueprintId = this.copyTarget.getAttribute('data-blueprint-id');
      if (blueprintId) {
        // Spinny spin is added
        this.iconTarget.classList.remove('fa-copy');
        this.iconTarget.classList.add('fa-spinner');
        this.iconTarget.classList.add('fa-spin');

        // Add code to clipboard
        const code = await this.fetchBlueprintCode(blueprintId);
        navigator.clipboard.writeText(code);

        // Display tooltip
        const tooltip = tippy(this.copyTarget, {
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
      }
    });

  }

  disconnect() {
    this.copyTarget.removeEventListener('click', (e) => e.preventDefault());
  }

  get usageTrackerController() {
    return this.application.getControllerForElementAndIdentifier(document.querySelector("[data-controller*='usageTracker']"), "usageTracker")
  }

  async fetchBlueprintCode(blueprintId) {
    const response = await fetch(`/blueprints/${blueprintId}/code`);
    const code = await response.text();
    this.blueprintCode = code;

    // Spinny spin is removed
    this.iconTarget.classList.remove('fa-spinner');
    this.iconTarget.classList.remove('fa-spin');
    this.iconTarget.classList.add('fa-copy');
    return code;
  }
}
