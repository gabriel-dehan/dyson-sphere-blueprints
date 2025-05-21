class Comment < ApplicationRecord
  belongs_to :blueprint
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  default_scope { order(created_at: :desc) }
  scope :roots, -> { where(parent_id: nil) }
end 