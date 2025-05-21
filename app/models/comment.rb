class Comment < ApplicationRecord
  belongs_to :blueprint
  belongs_to :user

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  default_scope { order(created_at: :desc) }
end 