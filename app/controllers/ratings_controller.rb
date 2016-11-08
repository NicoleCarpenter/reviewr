class RatingsController < ApplicationController

  def new
    @rating = Rating.new
    @thumb = params[:thumb]
    @random = params[:random]
    @review = Review.find(params[:review_id])
    @user = User.find(params[:user])
    if request.xhr?
      if @random
        render partial: "ratings/random_new"
      else
        render partial: "ratings/new"
      end
    end
  end

  def create
    rating = Rating.new(helpful: rating_params[:helpful],
                        explanation: rating_params[:explanation])
    if rating.save
      ReviewRating.create(review_id: rating_params[:review_id],
                          rating_id: rating.id)
      UserRating.create(user_id: rating_params[:user_id],
                        rating_id: rating.id)
      if request.xhr?
        render :js => "if (window.location.pathname == '#{root_path}') {
                         url.redirectToURI('#{root_path}');
                       } else {
                         url.redirectToURI('#{user_path(rating_params[:user_id])}');
                       };"
      else
        redirect_to review_path(rating_params[:review_id])
      end
    else
      if rating.helpful == false and rating.explanation.blank?
        if request.xhr?
          render :js => "dom.replaceContent('.alert-error', '<p>Please provide an explanation</p><br />');"
        else
          redirect_to new_rating_path(rating_params[:review_id]), { flash: { error: "Please provide an explanation" } }
        end
      else
        if request.xhr?
          render :js => "dom.replaceContent('.alert-error', '<p>Please select a button</p><br />');"
        else
          redirect_to new_rating_path(rating_params[:review_id]), { flash: { error: "Please select a button" } }
        end
      end
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:helpful, :explanation, :review_id, :user_id)
  end
end
