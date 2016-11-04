require 'rails_helper'

RSpec.describe User do
  it 'has a name, email and password' do
    user = User.new(name: "Joe",
                    email: "joe@example.com",
                    password: "password")

    expect(user.name).to eq("Joe")
    expect(user.email).to eq("joe@example.com")
    expect(user.password).to eq("password")
  end

  it 'has many projects' do
    user = User.create(name: "Joe",
                       email: "joe@example.com",
                       password: "password")
    project1 = create(:project, title: "Title1", description: "Description1")
    project2 = create(:project, title: "Title2", description: "Description2")
    project3 = create(:project, title: "Title3", description: "Description3")
    create(:user_project, user_id: user.id,
                          project_id: project1.id)
    create(:user_project, user_id: user.id,
                          project_id: project2.id)
    create(:user_project, user_id: user.id,
                          project_id: project3.id)

    expect(user.user_projects.length).to eq(3)
  end
end
