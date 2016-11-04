require 'rails_helper'

RSpec.describe UserProject do
  it 'belongs to a user and a project' do
    user = create(:user)
    project = create(:project)
    user_project = UserProject.new(user_id: user.id,
                                     project_id: project.id)

    expect(user_project.user).to eq(user)
    expect(user_project.project).to eq(project)
  end
end
