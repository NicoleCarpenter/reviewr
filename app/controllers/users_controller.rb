class UsersController < ApplicationController
  def show
    @user = User.find_by_id(params[:id])
    if session[:user_id] != @user.id
      redirect_to user_path(session[:user_id])
    end
  end
end
