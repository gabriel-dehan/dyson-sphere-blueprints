import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "container" ]

  connect() {
    const modsData = JSON.parse(this.containerTarget.dataset.mods);
    const includeBlank = this.containerTarget.dataset.includeBlank === 'true';
    const idSelect = this.containerTarget.querySelector('#blueprint_mod_id, #mod_id');
    const versionSelect = this.containerTarget.querySelector('#blueprint_mod_version, #mod_version');

    idSelect.addEventListener('change', () => {
      const selectedId = idSelect.value;
      const selectedMod = modsData.find((mod) => selectedId == mod['id'])

      let options = [];
      if (selectedMod) {
        options = selectedMod
          .versions
          .sort()
          .reverse()
          .map((version) => {
            return `<Option value="${version}">${version}</Option>`;
          });
      }

      if (includeBlank) {
        options = [...['<Option value>Any</Option>'], ...options];
      }

      versionSelect.innerHTML = options.join("\n");

    });

  }

}
