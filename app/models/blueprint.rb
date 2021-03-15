class Blueprint < ApplicationRecord
  extend FriendlyId
  acts_as_votable
  acts_as_taggable_on :tags

  has_one_attached :cover
  has_many_attached :pictures

  belongs_to :collection
  has_one :user, through: :collection

  friendly_id :title, use: :slugged

  validates :title, presence: true
  validates :encoded_blueprint, presence: true

  validates :tag_list, length: { minimum: 1, message: "needs at least one tag." }

  validates :cover,
    attached: true,
    content_type: [:png, :jpg, :jpeg],
    dimension: {
      width: { max: 2800 },
      height: { max: 2000 },
      message: 'is too large'
    }

  validates :pictures,
    limit: { max: 5 },
    content_type: [:png, :jpg, :jpeg],
    dimension: {
      width: { max: 2800 },
      height: { max: 2000 },
      message: 'is too large'
    }
end
