module ApplicationHelper

  def get_game_icon(name)
    # TODO: Refacto in a tag list with icons
    if name.downcase === "mall"
      icon_name = '2303'
    elsif name.downcase === "research"
      icon_name = '2901'
    else
      entity = Blueprint::game_data.find { |id, entity_name| entity_name.downcase == name.downcase }
      icon_name = entity ? entity[0] : 'default'
    end

    begin
      image_path "game_icons/#{icon_name}.png"
    rescue
      image_path "game_icons/default.png"
    end
  end

  def get_game_icon_by_uuid(uuid)
    file = uuid.blank? ? 'default' : uuid

    begin
      image_path "game_icons/#{file}.png"
    rescue
      image_path "game_icons/default.png"
    end
  end

  def get_game_entity_name_by_uuid(uuid)
    entity = Blueprint::game_data.find { |id, entity_name| id.to_s == uuid.to_s }
    entity ? entity[1] : "Unknown"
  end

  def pluralize_without_count(count, text)
    if count != 0
      count == 1 ? "#{text}" : "#{text.pluralize}"
    end
    text
  end

end
