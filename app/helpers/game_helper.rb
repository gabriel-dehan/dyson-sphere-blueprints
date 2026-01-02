module GameHelper
  def localized_entity_name(entity_uuid)
    Engine::Entities.instance.get_name(entity_uuid, locale: I18n.locale)
  end

  def localized_recipe_name(recipe_uuid)
    Engine::Recipes.instance.get_name(recipe_uuid, locale: I18n.locale)
  end

  def localized_research_name(research_uuid)
    Engine::Researches.instance.get_name(research_uuid, locale: I18n.locale)
  end

  def locale_display_name(locale)
    {
      en: "🇺🇸 English",
      "zh-CN": "🇨🇳 简体中文",
    }[locale.to_sym] || locale.to_s
  end
end
