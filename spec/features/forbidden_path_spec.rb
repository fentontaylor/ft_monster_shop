require 'rails_helper'

describe 'Visitor navigates to non-existant URI' do
  it 'Renders 404' do
    visit '/nonexistant_path'

    expect(page).to have_content("The page you were looking for doesn't exist.")
  end
end
