class Picture < ApplicationRecord
  include PictureUploader::Attachment(:picture)

  belongs_to :blueprint

  validates :picture, presence: true
end
