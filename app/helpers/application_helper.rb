module ApplicationHelper

  def get_game_icon(name)
    # TODO: Refacto in a tag list with icons
    if name.downcase === "mall"
      icon_name = '2303'
    else
      entity = Blueprint::game_data.find { |id, entity_name| entity_name.downcase == name.downcase }
      icon_name = entity ? entity[0] : 'default'
    end

    image_path "game_icons/#{icon_name}.png"
  end

  def get_game_icon_by_uuid(uuid)
    image_path "game_icons/#{uuid}.png"
  end

  def get_game_entity_name_by_uuid(uuid)
    entity = Blueprint::game_data.find { |id, entity_name| id.to_s == uuid.to_s }
    entity ? entity[1] : "Unknown"
  end

end
