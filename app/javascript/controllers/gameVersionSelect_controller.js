import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "container" ]

  connect() {
    const gameVersionsData = JSON.parse(this.containerTarget.dataset.gameVersions);
    const includeBlank = this.containerTarget.dataset.includeBlank === 'true';
    const idSelect = this.containerTarget.querySelector('#blueprint_game_version_id, #game_version_id');
    const versionSelect = this.containerTarget.querySelector('#blueprint_game_version_string, #game_version_string');

    idSelect.addEventListener('change', () => {
      const selectedId = idSelect.value;
      const selectedGameVersion = gameVersionsData.find((gv) => selectedId == gv['id'])

      let options = [];
      if (selectedGameVersion) {
        options = selectedGameVersion
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
