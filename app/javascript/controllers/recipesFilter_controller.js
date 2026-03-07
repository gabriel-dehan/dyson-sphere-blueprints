import { Controller } from "stimulus";
import Tagify from "@yaireo/tagify";
import { getRecipes, t } from "../i18n";

const buildRecipeIconUrl = (value) => {
  const id = value && value !== "0" ? value : "default";
  const base = window._cdnURL || "";
  return `${base}/public/game_icons/recipes/${id}.png`;
};

export default class extends Controller {
  static targets = ["input"];
  static values = { selected: Array };

  initialize() {
    const recipes = getRecipes();
    this.whitelist = Object.entries(recipes)
      .map(([id, name]) => ({ value: id.toString(), name }))
      .sort((a, b) => a.name.localeCompare(b.name));
  }

  connect() {
    const tagTemplate = function (tagData) {
      const label = tagData.name || tagData.value;
      return `
        <tag title="${this.escapeHTML(label)}"
          contenteditable='false'
          spellcheck='false'
          tabindex="-1"
          class="tagify__tag"
          ${this.getAttributes(tagData)}>
          <x title='remove tag' class='tagify__tag__removeBtn'></x>
          <div class="tagify__tag__content">
            <img class="tagify__tag__icon" src="${buildRecipeIconUrl(tagData.value)}" alt="" loading="lazy" />
            <span class='tagify__tag-text'>${this.escapeHTML(label)}</span>
          </div>
        </tag>
      `;
    };

    const dropdownItemTemplate = function (tagData) {
      const label = tagData.name || tagData.value;
      return `
        <div class="tagify__dropdown__item" ${this.getAttributes(tagData)}>
          <img class="tagify__tag__icon" src="${buildRecipeIconUrl(tagData.value)}" alt="" loading="lazy" />
          <span>${this.escapeHTML(label)}</span>
        </div>
      `;
    };

    this.tagify = new Tagify(this.inputTarget, {
      whitelist: this.whitelist,
      tagTextProp: "name",
      enforceWhitelist: true,
      editTags: false,
      originalInputValueFormat: (valuesArr) => valuesArr.map((item) => item.value).join(","),
      dropdown: {
        enabled: 0,
        maxItems: 20,
        searchKeys: ["name", "value"],
      },
      templates: {
        tag: tagTemplate,
        dropdownItem: dropdownItemTemplate,
      },
      placeholder: t("recipes.filters.placeholder"),
    });

    if (this.hasSelectedValue && this.selectedValue.length) {
      const initialTags = this.selectedValue.map((value) => {
        return this.whitelist.find((recipe) => recipe.value === value.toString()) || { value: value.toString(), name: value.toString() };
      });
      this.tagify.addTags(initialTags);
    }
  }

  disconnect() {
    if (this.tagify) {
      this.tagify.destroy();
    }
  }
}
