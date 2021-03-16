import { Controller } from "stimulus"
import ActiveStorageDragAndDrop from "../vendor/active_storage_drag_and_drop"

export default class extends Controller {
  connect() {
    ActiveStorageDragAndDrop.start()
  }
}
