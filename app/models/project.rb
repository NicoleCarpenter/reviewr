class Project < ApplicationRecord
  validates :title, :description, presence: true

  has_many :project_reviews
  has_many :reviews, through: :project_reviews

  has_many :user_projects
  has_many :users, through: :user_projects

end
