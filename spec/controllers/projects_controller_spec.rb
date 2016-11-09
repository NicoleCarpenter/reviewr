require 'spec_helper'

RSpec.describe ProjectsController, :type => :controller do
  render_views

  describe 'GET /projects' do
    it 'renders template for index' do
      project1 = create(:project)
      project2 = create(:project, title: "Java Tic-Tac-Toe")
      review = create(:review, content: "Looks good!")

      get :index

      expect(response.status).to eq(200)
      expect(response.body).to include(project1.title)
      expect(response.body).to include(project2.title)
    end

    it 'includes a link to new project' do
      review = create(:review, content: "Looks good!")

      get :index

      expect(response.body).to include('create new project')
    end

    it 'displays a random review to rate' do
      review = create(:review, content: "Looks good!")
      
      get :index

      expect(response.body).to render_template('reviews/_show')
    end
  end

  describe 'GET /projects/new' do
    it 'redirects to root if not logged in' do
      get :new

      expect(response).to have_http_status(:redirect)
    end

    it 'renders the template for the project new page if logged in' do
      user = create(:user)
      session[:user_id] = user.id 

      get :new

      expect(response.body).to include("Title")
      expect(response.body).to include("Description")
    end
  end

  describe 'POST /projects/new' do
    it 'creates a new project and redirects to the project index page' do
      post :create, params: { project: { title: 'my project', description: 'a description' } }

      expect(response).to redirect_to(projects_path)
      expect(response).to have_http_status(:redirect)
    end

    it 'displays flash message if title is blank' do
      post :create, params: { project: { title: '', description: 'a description' } }

      expect(response).to redirect_to(new_project_path)
      expect(flash[:error]).to match("Please provide a title")
    end

    it 'displays flash message if description is blank' do
      post :create, params: { project: { title: 'my project', description: '' } }

      expect(response).to redirect_to(new_project_path)
      expect(flash[:error]).to match("Please provide a description")
    end
  end

  describe 'GET /projects/:id' do
    it 'redirects to root if you are not logged in' do
      project = create(:project)

      get :show, params: { id: project.id }

      expect(response).to have_http_status(:redirect)
    end

    it 'redirects to root if you are not logged in as the owner' do
      project = create(:project)
      owner = create(:user, name: 'name1',
                            email: 'name1@email.com',
                            uid: 'uidname1')
      user = create(:user, name: 'name2',
                           email: 'name2@email.com',
                           uid: 'uidname2')
      create(:project_owner, project_id: project.id,
                             user_id: owner.id)
      session[:user_id] = user.id

      get :show, params: { id: project.id }

      expect(response).to have_http_status(:redirect)
    end
      
    it 'renders the template for the project show page when logged in as the owner' do
      project = create(:project)
      owner = create(:user, name: 'name',
                            email: 'name@email.com',
                            uid: 'uidname')
      create(:project_owner, project_id: project.id,
                             user_id: owner.id)
      session[:user_id] = owner.id

      get :show, params: { id: project.id }

      expect(response.status).to eq(200)
      expect(response.body).to include(project.title)
      expect(response.body).to include(project.description)
    end

    it 'includes reviews associated with the project when logged in as the owner' do
      project = create(:project)
      owner = create(:user, name: 'name',
                            email: 'name@email.com',
                            uid: 'uidname')
      create(:project_owner, project_id: project.id,
                             user_id: owner.id)
      session[:user_id] = owner.id
      review1 = create(:review, content: "Looks good!")
      review2 = create(:review, content: "Huh?")
      create(:project_review, project_id: project.id,
                              review_id: review1.id)
      create(:project_review, project_id: project.id,
                              review_id: review2.id)

      get :show, params: { id: project.id }

      expect(response.body).to include(review1.content)
      expect(response.body).to include(review2.content)
    end

    it 'includes a link to edit the project when logged in as the owner' do
      project = create(:project)
      owner = create(:user, name: 'name',
                            email: 'name@email.com',
                            uid: 'uidname')
      create(:project_owner, project_id: project.id,
                             user_id: owner.id)
      session[:user_id] = owner.id

      get :show, params: { id: project.id }

      expect(response.body).to include("edit")
    end
  end

  describe 'GET /projects/:id/edit' do
    it 'redirects when not logged in' do
      project = create(:project)
      
      get :edit, params: { id: project.id }

      expect(response).to have_http_status(:redirect)
    end

    it 'redirects when logged in as user who is not project owner' do
      project = create(:project)
      owner = create(:user, name: 'name1',
                            email: 'name1@email.com',
                            uid: 'uidname1')
      user = create(:user, name: 'name2',
                           email: 'name2@email.com',
                           uid: 'uidname2')
      create(:project_owner, project_id: project.id,
                             user_id: owner.id)
      session[:user_id] = user.id

      get :edit, params: { id: project.id }

      expect(response).to have_http_status(:redirect)
    end

    it 'renders the template for the project edit page when logged in as the project owner' do
      project = create(:project)
      owner = create(:user)
      create(:project_owner, project_id: project.id,
                             user_id: owner.id)
      session[:user_id] = owner.id

      get :edit, params: { id: project.id }

      expect(response).to have_http_status(200)
      expect(response.body).to include("Title")
      expect(response.body).to include(project.title)
      expect(response.body).to include("Description")
      expect(response.body).to include(project.description)
    end
  end

  describe 'POST /projects/:id/edit' do
    it 'edits the project and redirects to the index page with flash notice of changes' do
      project = create(:project)

      post :update, params: { id: project.id, project: { title: 'best title', description: 'best description' } }
      
      updated_project = Project.find_by_id(project.id)
      expect(response).to redirect_to(project_path(project.id))
      expect(response).to have_http_status(:redirect)
      expect(updated_project.title).to eq('best title')
      expect(updated_project.description).to eq('best description')
      expect(flash[:notice]).to match('Project has been updated')
    end

    it 'displays flash error message if description is blank' do
      project = create(:project)

      post :update, params: { id: project.id, project: { title: 'best title', description: '' } }
      
      expect(response).to redirect_to(edit_project_path(project.id))
      expect(flash[:error]).to match("Please provide a description")
    end

    it 'displays flash error message if title is blank' do
      project = create(:project)

      post :update, params: { id: project.id, project: { title: '', description: 'best description' } }
      
      expect(response).to redirect_to(edit_project_path(project.id))
      expect(flash[:error]).to match("Please provide a title")
    end
  end
end
