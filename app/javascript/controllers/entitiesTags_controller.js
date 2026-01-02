import { Controller } from "stimulus"
import Tagify from '@yaireo/tagify'
import GameEntities from '../data/gameEntities.json';
import GameTags from '../data/additionalTags.json';
import { getEntities, t } from '../i18n';

export default class extends Controller {
  static targets = [ "input" ]

  initialize() {
    // Use English entity names for tag storage (database uses English)
    // But show localized names in dropdown
    const localizedEntities = getEntities();
    this.whitelist = [...Object.keys(GameTags), ...Object.values(GameEntities)]

    // For Chinese users, also add Chinese names to whitelist for easier searching
    // but they map to English values for storage
    const currentLocale = document.documentElement.lang || 'en';
    if (currentLocale === 'zh-CN') {
      // Create mapping of Chinese to English for suggestions
      this.chineseToEnglish = {};
      Object.keys(GameEntities).forEach(id => {
        const englishName = GameEntities[id];
        const chineseName = localizedEntities[id];
        if (chineseName && chineseName !== englishName) {
          this.chineseToEnglish[chineseName] = englishName;
          this.whitelist.push(chineseName);
        }
      });
    }
  }

  connect() {
    const currentLocale = document.documentElement.lang || 'en';
    const placeholder = currentLocale === 'zh-CN'
      ? "搜索标签：商城、原油精炼、分馏塔..."
      : "Search for a tag: mall, oil refinery, fractionator...";

    const tagify = new Tagify(
      this.inputTarget, {
        placeholder: placeholder,
        whitelist: this.whitelist,
        enforceWhitelist: true,
        editTags: false,
        originalInputValueFormat: valuesArr => valuesArr.map(item => {
          // Convert Chinese tag names back to English for storage
          if (this.chineseToEnglish && this.chineseToEnglish[item.value]) {
            return this.chineseToEnglish[item.value];
          }
          return item.value;
        }).join(',')
      }
    );
  }
}
