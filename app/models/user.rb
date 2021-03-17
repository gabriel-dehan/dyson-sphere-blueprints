class User < ApplicationRecord
  acts_as_voter

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable

  has_many :collections, dependent: :destroy
  has_many :blueprints, through: :collections

  before_create :create_default_collections

  validates :username, uniqueness: true

  def admin?
    role == 'admin'
  end

  private

  def create_default_collections
    self.collections.new(name: "Public", type: "Public")
    self.collections.new(name: "Private", type: "Private")
  end
end
