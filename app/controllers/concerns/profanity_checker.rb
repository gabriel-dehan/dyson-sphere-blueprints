module ProfanityChecker
  extend ActiveSupport::Concern

  # Custom words not handled by profanity filter gem
  PROFANE_DICT = %w[hitler hiitler hitleer hiitleer penis peniis dick diick].freeze

  included do
    def profane?(string)
      PROFANE_DICT.include?(string.downcase) || ProfanityFilter.new.profane?(string)
    end
  end
end
