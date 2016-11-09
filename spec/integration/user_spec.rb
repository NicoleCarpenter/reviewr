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
                               { uid: 'uidhillaryclinton',
                                 info: { name: 'hillaryclinton',
                                         email: 'hillaryclinton@email.com' } })

      visit '/'
      find_link('Sign in with Google').click

      expect(page).to have_link('Sign out')
    end
  end
end
