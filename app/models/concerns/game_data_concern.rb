module GameDataConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def game_data
      @game_data ||= JSON.parse(File.read(Rails.root.join('app', 'javascript', 'data', 'gameEntities.json')))
    end
  end
end
