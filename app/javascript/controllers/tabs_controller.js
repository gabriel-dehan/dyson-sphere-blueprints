import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "select", "tab" ]

  connect() {
    const selectors = this.selectTarget.querySelectorAll('[data-tab-select]');
    const tabs = this.tabTargets;

    selectors.forEach((selector) => {
      selector.addEventListener('click', () => {
        const targetId = selector.dataset['tabSelect'];
        const target = tabs.find(tab => tab.dataset['tabsId'] == targetId);
        console.log(tabs, targetId, target)
        selectors.forEach(sel => sel.classList.remove('active'))
        tabs.forEach(tab => tab.classList.remove('active'))
        selector.classList.add('active');
        target.classList.add('active');
      })
    })
  }
}