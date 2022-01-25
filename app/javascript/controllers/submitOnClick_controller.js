import { Controller } from "stimulus"

export default class extends Controller {
  submit() {
    this.element.closest("form").submit();
  }
}
