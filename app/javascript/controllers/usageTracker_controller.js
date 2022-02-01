import { Controller } from "stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
  track(event, id) {
    const blueprintId = id || this.element.dataset.blueprintId;
    Rails.ajax({
      type: "PUT",
      dataType: 'json',
      url: `/blueprints/${blueprintId}/track.json`
    });
  }
}
