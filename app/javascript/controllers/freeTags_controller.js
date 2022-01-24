import { Controller } from "stimulus"
import Tagify from '@yaireo/tagify'
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "input", "error" ]
  static values = {
    category: String
  }

  initialize() {
  }

  connect() {
    Rails.ajax({
      type: "GET",
      dataType: 'json',
      url: `/tags.json?category=${this.categoryValue}`,
      success: (whitelist) => {
        const tagify = new Tagify(
        this.inputTarget, {
          placeholder: "Search for a tag or add a new one",
          whitelist: whitelist.map((tag) => ({ value: tag, class: 'whitelist' })),
          editTags: true,
          originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
        });

        tagify.on('add', (tag) => {
          const value = tag.detail.data.value;
          if (whitelist.includes(value)) {
            return;
          }

          this.errorTarget.textContent = '';
          tagify.loading(true);

          Rails.ajax({
            type: "POST",
            dataType: 'json',
            url: "/tags/profanity_check.json",
            data: (new URLSearchParams(`tag=${value}`)).toString(),
            success: (isProfane) => {
              tagify.loading(false);
              if (isProfane) {
                tagify.removeTags(value);
                this.errorTarget.textContent = `${value} is a prohibited word.`
              }
            }
          })
        });

        tagify.on('blur', () => this.errorTarget.textContent = '');

        // TODO: Save tags on blur?
        // Rails.ajax({
          //   type: "POST",
          //   dataType: 'json',
          //   url: "/tags.json",
          //   data: (new URLSearchParams(`category=${this.categoryValue}&tag=${value}`)).toString(),
          //   success: (isValid) => {
          //     tagify.loading(false);
          //     if (!isValid) {
          //       tagify.removeTags(value);
          //       this.errorTarget.textContent = `${value} is a prohibited word.`
          //     }
          //   }
          // })
      }
    })
  }
}
