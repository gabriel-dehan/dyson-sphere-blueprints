import ClipboardJS from 'clipboard';
import { Controller } from "stimulus"
import tippy from 'tippy.js';
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "copy" ]

  connect() {
    this.clipboard = new ClipboardJS(this.copyTarget, {
      text: () => {
        const dataAttribute = this.copyTarget.getAttribute('data-clipboard-text');
        if (dataAttribute) {
          return dataAttribute;
        } else {
          return document.querySelector('[data-clipboard-target="true"]').value;
        }
      }
    });

    this.clipboard.on('success', (e) => {
      const tooltip = tippy(e.trigger, {
        content: 'Copied !',
        trigger: "manual",
        duration: 200,
        onHidden: instance => instance.destroy(),
      });

      tooltip.show();

      Rails.ajax({
        type: "PUT",
        dataType: 'json',
        url: `/NEED_ID_IN_HTML_AT_TO_SHOW_AND_DONT_FORGET_TO_CREATE_CONTROLLER_FOR_DOWNLOAD_TOO_tags.json?category=${this.categoryValue}`,
        success: (whitelist) => {
          const tagify = new Tagify(
          this.inputTarget, {
            placeholder: "Search for a tag or add a new one",
            whitelist: whitelist.map((tag) => ({ value: tag, class: 'whitelist' })),
            editTags: true,
            originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
          });
        }
      });

      setTimeout(() => {
        tooltip.hide();
      }, 800);

    });
  }

  disconnect() {
    this.clipboard.destroy();
  }
}
