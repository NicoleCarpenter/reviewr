class User < ApplicationRecord
  validates :name, :email, :password, presence: true

  has_many :user_projects
  has_many :projects, through: :user_projects
end
