require 'spec_helper'

RSpec.describe UsersController, :type => :controller do
  render_views

  describe 'GET /users/:id' do
    it 'redirects to root if you are not logged in as that user' do
      user1 = create(:user, name: 'name1',
                            email: 'name1@email.com',
                            uid: 'uidname1')
      user2 = create(:user, name: 'name2',
                            email: 'name2@email.com',
                            uid: 'uidname2')
      session[:user_id] = user1.id

      get :show, params: { id: user2.id }

      expect(response).to have_http_status(:redirect)
    end
  end
end
