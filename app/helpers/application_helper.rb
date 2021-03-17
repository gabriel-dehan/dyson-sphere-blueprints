module ApplicationHelper

  def get_game_icon(name)
    entity = Blueprint::game_data.find { |id, entity_name| entity_name.downcase == name.downcase }
    icon_name = entity ? entity[0] : 'default'
    image_path "game_icons/#{icon_name}.png"
  end
end
