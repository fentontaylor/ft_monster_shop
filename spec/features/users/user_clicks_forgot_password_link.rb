require 'rails_helper'

describe 'User clicks forgot password link on login page' do
  it 'Send them an email with instructions to reset the password' do
    user = create(:user)

    visit '/login'

    click_link 'Forgot yo password?'

    fill_in 'Email', with: user.email

    click_on 'Reset Password'
  end
end
