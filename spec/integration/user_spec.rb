require 'spec_helper'

describe 'user', :type => :feature do
  describe 'logged out index page' do
    it 'has a link to Google authentication' do 
      visit '/'

      expect(page).to have_link('Sign in with Google')
    end
  end

  describe 'logged in index page' do
    it 'has a link to log out' do
      OmniAuth.config.add_mock(:google_oauth2,
                               { uid: 'uid',
                                 info: { name: 'name',
                                         email: 'name@email.com' } })
      visit '/'
      click_link('Sign in with Google')

      expect(page).to have_link('Sign out')
    end
  end

  describe 'show page' do
    describe 'projects tab' do
      it 'shows projects that belong to the user' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        project1 = create(:project, title: 'Rust Http Server')
        project2 = create(:project, title: 'Java Tic-Tac-Toe')
        create(:project_owner, project_id: project1.id,
                               user_id: user.id)
        create(:project_owner, project_id: project2.id,
                               user_id: user.id)

        visit user_path(id: user)

        expect(page).to have_content(project1.title)
        expect(page).to have_content(project2.title)
      end

      it 'does not show projects that do not belong to the user' do
        user1 = create(:user, name: 'Name 1', email: 'name1@example.com')
        user2 = create(:user, name: 'Name 2', email: 'name2@example.com')
        project = create(:project, title: 'Rust Http Server')
        create(:project_owner, project_id: project.id,
                               user_id: user2.id)

        visit user_path(id: user1)

        expect(page).to have_no_content(project.title)
      end

      it 'shows all projects as links' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        project1 = create(:project, title: 'Rust Http Server')
        project2 = create(:project, title: 'Java Tic-Tac-Toe')
        create(:project_owner, project_id: project1.id,
                               user_id: user.id)
        create(:project_owner, project_id: project2.id,
                               user_id: user.id)

        visit user_path(id: user)

        expect(page).to have_link(project1.title)
        expect(page).to have_link(project2.title)
      end

      it 'navigates to project show page when project title is clicked' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        project = create(:project, title: 'Rust Http Server')
        create(:project_owner, project_id: project.id,
                               user_id: user.id)

        visit user_path(id: user)
        click_link('Rust Http Server')

        expect(current_path).to eq('/projects/' + project.id.to_s)
      end

      it 'navigates to new project page when new project link is clicked' do
        user = create(:user, name: 'Name', email: 'name@example.com')

        visit user_path(id: user)
        click_link('+ create new project')

        expect(page).to have_css('form')
        expect(current_path).to eq('/projects/new')
      end

      it 'shows projects in reverse chronological order' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        project1 = create(:project, title: 'Rust Http Server')
        project2 = create(:project, title: 'Java Tic-Tac-Toe')
        create(:project_owner, project_id: project1.id,
                               user_id: user.id)
        create(:project_owner, project_id: project2.id,
                               user_id: user.id)

        visit user_path(id: user)

        expect(page.body.index(project1.title)).to be > page.body.index(project2.title)
      end
    end

    describe 'reviews tab' do
      it 'shows reviews that belong to the user' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        review1 = create(:review, content: 'Looks good')
        review2 = create(:review, content: 'Looks terrible')
        create(:user_review, user_id: user.id,
                             review_id: review1.id)
        create(:user_review, user_id: user.id,
                             review_id: review2.id)

        visit user_path(id: user)

        expect(page).to have_content(review1.content)
        expect(page).to have_content(review2.content)
      end

      it 'does not show reviews that do not belong to the user' do
        user1 = create(:user, name: 'Name 1', email: 'name1@example.com')
        user2 = create(:user, name: 'Name 2', email: 'name2@example.com')
        review = create(:review, content: 'Looks good')
        create(:user_review, review_id: review.id,
                             user_id: user2.id)

        visit user_path(id: user1)

        expect(page).to have_no_content(review.content)
      end

      it 'shows all reviews as links' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        review1 = create(:review, content: 'Looks good')
        review2 = create(:review, content: 'Looks terrible')
        create(:user_review, user_id: user.id,
                             review_id: review1.id)
        create(:user_review, user_id: user.id,
                             review_id: review2.id)

        visit user_path(id: user)

        expect(page).to have_link(review1.content)
        expect(page).to have_link(review2.content)
      end

      it 'navigates to review show page when review content is clicked' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        review = create(:review, content: 'Looks terrible')
        create(:user_review, user_id: user.id,
                             review_id: review.id)

        visit user_path(id: user)
        click_link('Looks terrible')

        expect(current_path).to eq('/reviews/' + review.id.to_s)
      end

      it 'shows reviews in reverse chronological order' do
        user = create(:user, name: 'Name', email: 'name@example.com')
        review1 = create(:review, content: 'Looks good')
        review2 = create(:review, content: 'Looks terrible')
        create(:user_review, user_id: user.id,
                             review_id: review1.id)
        create(:user_review, user_id: user.id,
                             review_id: review2.id)

        visit user_path(id: user)

        expect(page.body.index(review1.content)).to be > page.body.index(review2.content)
      end
    end

    describe 'random review div' do
      it 'shows a random review to be rated' do
        user = create(:user, name: 'Name', email: 'name@example.com')

        visit user_path(id: user)

        expect(page).to have_content("Rate This Review")
      end

      it 'shows new rating form when thumbs up is clicked', :js => true do
        Capybara.ignore_hidden_elements = false
        user = create(:user, name: 'Name', email: 'name@example.com')

        visit user_path(id: user)
        find_by_id('random-rating-up').trigger('click')

        expect(page).to have_css('form')
        expect(page).to have_checked_field('rating_helpful_true')
        expect(page).to have_button('Rate review')
      end

      it 'shows new rating form when thumbs down is clicked', :js => true do
        Capybara.ignore_hidden_elements = false
        user = create(:user, name: 'Name', email: 'name@example.com')

        visit user_path(id: user)

        find_by_id('random-rating-down').trigger('click')

        expect(page).to have_css('form')
        expect(page).to have_checked_field('rating_helpful_false')
        expect(page).to have_button('Rate review')
      end
    end

  end
end
