import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "collapsible" ]

  connect() {
    const target = this.collapsibleTarget;
    target.style.display = 'none';
  }

  toggle() {
    const target = this.collapsibleTarget;
    if (target.style.display === 'none') {
      target.style.display = 'block';
    } else {
      target.style.display = 'none';
    }
  }
}
