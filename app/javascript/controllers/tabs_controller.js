import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "select", "tab" ]

  select(event) {
    const selectors = this.selectTarget.querySelectorAll('[data-tab-select]');
    const tabs = this.tabTargets;
    const targetId = event.target.dataset.tabSelect;
    const selector = this.selectTarget.querySelector(`[data-tab-select="${targetId}"]`);
    const target = tabs.find(tab => tab.dataset['tabsId'] == targetId);

    // Reset everything
    selectors.forEach(sel => sel.classList.remove('active'))
    tabs.forEach(tab => tab.classList.remove('active'))

    // Add active where needed
    selector.classList.add('active');
    target.classList.add('active');

    if (targetId === '3d-preview') {
      // Defer the execution just a tiny bit to give the tab change a chance
      setTimeout(() => this.previewController.render(), 500)

    }
  }

  get previewController() {
    return this.application.getControllerForElementAndIdentifier(document.querySelector("[data-controller*='preview']"), "preview")
  }
}