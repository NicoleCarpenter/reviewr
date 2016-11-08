class UsersController < ApplicationController

  def show
    @user = User.find_by_id(params[:id])
    @review = Review.offset(rand(Review.count)).first
    @projects = @user.projects.order(updated_at: :desc).all
    @reviews = @user.reviews.order(updated_at: :desc).all
  end
end