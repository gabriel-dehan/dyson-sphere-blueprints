class Comment < ApplicationRecord
  belongs_to :blueprint
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id'
  has_many :likes, as: :likable, dependent: :destroy

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  default_scope { order(created_at: :desc) }
  scope :roots, -> { where(parent_id: nil) }

  def deleted?
    deleted_at.present?
  end

  def liked_by?(user)
    likes.exists?(user: user)
  end

  def like_count
    likes.count
  end
end 