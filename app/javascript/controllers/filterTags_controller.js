import { Controller } from "stimulus"
import Tagify from '@yaireo/tagify'
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "input" ]
  static values = {
    category: String
  }

  initialize() {}

  connect() {
    Rails.ajax({
      type: "GET",
      dataType: 'json',
      url: `/tags.json?category=${this.categoryValue}`,
      success: (whitelist) => {
        this.tagify = new Tagify(
        this.inputTarget, {
          placeholder: "Search for any tag...",
          whitelist: whitelist.map((tag) => ({ value: tag, class: 'whitelist' })),
          editTags: false,
          originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
        });
      }
    })
  }

  disconnect() {
    // TODO:
  }
}
