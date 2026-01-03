// i18n helper module for JavaScript
// Provides locale-aware access to game entity and recipe names

import itemsEn from '../data/gameEntities.json';
import itemsZhCN from '../data/gameEntities.zh-CN.json';
import recipesEn from '../data/gameRecipes.json';
import recipesZhCN from '../data/gameRecipes.zh-CN.json';

// Get the current locale from the HTML lang attribute
export function getCurrentLocale() {
  return document.documentElement.lang || 'en';
}

// Get localized entity name
export function getEntityName(entityId) {
  const locale = getCurrentLocale();
  const items = locale === 'zh-CN' ? itemsZhCN : itemsEn;
  return items[entityId] || itemsEn[entityId] || 'Unknown';
}

// Get localized recipe name
export function getRecipeName(recipeId) {
  const locale = getCurrentLocale();
  const recipes = locale === 'zh-CN' ? recipesZhCN : recipesEn;
  return recipes[recipeId] || recipesEn[recipeId] || 'Unknown';
}

// Get all entities for current locale
export function getEntities() {
  const locale = getCurrentLocale();
  return locale === 'zh-CN' ? itemsZhCN : itemsEn;
}

// Get all recipes for current locale
export function getRecipes() {
  const locale = getCurrentLocale();
  return locale === 'zh-CN' ? recipesZhCN : recipesEn;
}

// UI string translations
const uiStrings = {
  en: {
    'filters.tags.placeholder': 'Search for any tag...',
    'freetags.placeholder': 'Search for a tag or add a new one...',
    'size_warning.quite_big': 'quite big',
    'size_warning.too_big': 'too big',
    'station.supply': 'Supply',
    'station.demand': 'Demand',
    'station.storage': 'Storage',
    'station.local': 'Local:',
    'station.remote': 'Remote:',
    'station.max': 'Max:',
    // Uppy file upload strings
    'uppy.drop_paste': 'Drop files here, paste or %{browse}',
    'uppy.browse': 'browse files',
    'uppy.single_note': 'Single cover picture. %{size} MB maximum, ideal ratio 16:9. For instance 1920x1080, etc...',
    'uppy.multiple_note': '%{max} pictures maximum, %{size} MB maximum each, ideal ratio 16:9. For instance 1920x1080, etc...',
    'uppy.reset': 'Reset',
    'uppy.mecha_title': 'Drop your mecha file here, or %{browse}',
    'uppy.mecha_description': 'Mecha blueprint file. 2 MB maximum',
    'uppy.mecha_error': 'Invalid mecha file',
    'uppy.validating': 'Validating file...'
  },
  'zh-CN': {
    'filters.tags.placeholder': '搜索任何标签...',
    'freetags.placeholder': '搜索标签或添加新标签...',
    'size_warning.quite_big': '相当大',
    'size_warning.too_big': '太大了',
    'station.supply': '供应',
    'station.demand': '需求',
    'station.storage': '存储',
    'station.local': '本地：',
    'station.remote': '星际：',
    'station.max': '最大：',
    // Uppy file upload strings
    'uppy.drop_paste': '拖放文件到此处，粘贴或 %{browse}',
    'uppy.browse': '浏览文件',
    'uppy.single_note': '单张封面图片。最大 %{size} MB，理想比例 16:9。例如 1920x1080 等...',
    'uppy.multiple_note': '最多 %{max} 张图片，每张最大 %{size} MB，理想比例 16:9。例如 1920x1080 等...',
    'uppy.reset': '重置',
    'uppy.mecha_title': '拖放机甲文件到此处，或 %{browse}',
    'uppy.mecha_description': '机甲蓝图文件。最大 2 MB',
    'uppy.mecha_error': '无效的机甲文件',
    'uppy.validating': '正在验证文件...'
  }
};

// Get translated UI string
export function t(key) {
  const locale = getCurrentLocale();
  const strings = uiStrings[locale] || uiStrings['en'];
  return strings[key] || uiStrings['en'][key] || key;
}
