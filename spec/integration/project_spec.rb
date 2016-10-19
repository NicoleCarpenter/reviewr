require 'spec_helper'

describe 'project show page' do
  it 'has a title and a description' do
    project1 = create(:project)

    visit "/projects/" + project1.id.to_s

    page.has_content? project1.title
    page.has_content? project1.description
  end
end
