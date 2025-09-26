class Like < ApplicationRecord
  belongs_to :likable, polymorphic: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: [:likable_type, :likable_id] }
end 