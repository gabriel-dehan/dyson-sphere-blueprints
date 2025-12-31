import { Controller } from "stimulus"
import tippy from 'tippy.js';

export default class extends Controller {
  connect() {
    tippy('.tooltip-trigger', {
      duration: 200,
    });
  }
}
