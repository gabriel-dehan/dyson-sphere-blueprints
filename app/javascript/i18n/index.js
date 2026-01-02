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
    'size_warning.quite_big': 'quite big',
    'size_warning.too_big': 'too big',
    'station.supply': 'Supply',
    'station.demand': 'Demand',
    'station.storage': 'Storage',
    'station.local': 'Local:',
    'station.remote': 'Remote:',
    'station.max': 'Max:'
  },
  'zh-CN': {
    'size_warning.quite_big': '相当大',
    'size_warning.too_big': '太大了',
    'station.supply': '供应',
    'station.demand': '需求',
    'station.storage': '存储',
    'station.local': '本地：',
    'station.remote': '星际：',
    'station.max': '最大：'
  }
};

// Get translated UI string
export function t(key) {
  const locale = getCurrentLocale();
  const strings = uiStrings[locale] || uiStrings['en'];
  return strings[key] || uiStrings['en'][key] || key;
}
