module ApplicationHelper

  def get_game_entity_icon_by_name(name)
    # TODO: Refacto in a tag list with icons
    if name.downcase === "mall"
      icon_name = '2303'
    elsif name.downcase === "research"
      icon_name = '2901'
    else
      icon_name = Engine::Entities.get_uuid(name) || 'default'
    end

    begin
      image_path "game_icons/entities/#{icon_name}.png"
    rescue
      image_path "game_icons/entities/default.png"
    end
  end

  def get_game_entity_icon_by_uuid(uuid)
    file = uuid.blank? ? 'default' : uuid

    begin
      image_path "game_icons/entities/#{file}.png"
    rescue
      image_path "game_icons/entities/default.png"
    end
  end

  def get_game_recipe_icon_by_uuid(uuid)
    file = uuid.blank? ? 'default' : uuid

    begin
      image_path "game_icons/recipes/#{file}.png"
    rescue
      image_path "game_icons/recipes/default.png"
    end
  end

  def pluralize_without_count(count, text)
    if count != 0
      count == 1 ? "#{text}" : "#{text.pluralize}"
    end
    text
  end

end
