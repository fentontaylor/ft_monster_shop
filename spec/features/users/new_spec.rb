require 'rails_helper'

describe 'User clicks link to sign up' do
  before :each do
    @name = 'Bobb'
    @email = 'bobb@gmail.com'
    @password = 'supersafe'
  end

  it 'They are taken to a form to register' do
    visit '/'

    within '.login-options' do
      click_link 'Sign Up'
    end

    expect(current_path).to eq('/register')

    fill_in 'Name', with: @name
    fill_in 'Email', with: @email
    fill_in 'Password', with: @password
    fill_in 'Password confirmation', with: @password

    click_on 'Submit'

    expect(current_path).to eq('/profile')
  end

  it 'The field cant have blanks' do
    visit '/register'

    click_on 'Submit'

    expect(page).to have_content("Name can't be blank, Password confirmation doesn't match Password, Email can't be blank, and Password can't be blank")
  end

  it 'Cant reuse email addresses' do
    user = User.create(name: @name, email: @email, password: @password)
    visit '/register'

    fill_in 'Name', with: @name
    fill_in 'Email', with: @email
    fill_in 'Password', with: @password
    fill_in 'Password confirmation', with: @password

    click_on 'Submit'

    expect(page).to have_content('Email has already been taken')
  end
  
  it "needs matching passwords" do
    visit '/register'

    fill_in 'Name', with: @name
    fill_in 'Email', with: @email
    fill_in 'Password', with: @password
    fill_in 'Password confirmation', with: 'something_random'

    click_on 'Submit'

    expect(page).to have_content("Password confirmation doesn't match Password")
  end
end
