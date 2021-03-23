class Picture < ActiveRecord::Base
  include PictureUploader::Attachment(:picture)

  belongs_to :blueprint

  validates :picture, presence: true
end