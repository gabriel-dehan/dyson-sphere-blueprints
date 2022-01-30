import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "select", "tab" ]

  select(event) {
    const selectors = this.selectTarget.querySelectorAll('[data-toggleableTabs-select]');
    const tabs = this.tabTargets;
    const targetId = event.currentTarget.dataset.toggleabletabsSelect;
    const selector = this.selectTarget.querySelector(`[data-toggleableTabs-select="${targetId}"]`);
    const target = tabs.find(tab => tab.dataset['tabsId'] == targetId);
    const wasActive = selector.classList.contains('active');

    // Reset everything
    selectors.forEach(sel => sel.classList.remove('active'))
    tabs.forEach(tab => tab.classList.remove('active'))

    if (!wasActive) {
      selector.classList.add('active');
      target.classList.add('active');
    }
  }
}