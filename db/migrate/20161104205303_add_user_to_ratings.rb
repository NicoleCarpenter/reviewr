class AddUserToRatings < ActiveRecord::Migration[5.0]
  def change
    add_reference :ratings, :user, index: true
    add_foreign_key :ratings, :users
  end
end
