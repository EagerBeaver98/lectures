npm install -g phantomjs

group :development, :test do
  #add
  gem 'capybara' 
  gem 'poltergeist'
  gem 'database_cleaner'
end

bundle install

# add to rails_helper.rb 
require "capybara/rails"
require "capybara/rspec"
require "capybara/poltergeist" # Add this line to require poltergeist

# Specs flagged with `js: true` will use Capybara's JS driver. Set
# that JS driver to :poltergeist
Capybara.javascript_driver = :poltergeist

# set to false
config.use_transactional_fixtures = false

#UNCOMMENT
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }
#This tells RSpec to also require all files within the spec/support folder. This folder presently does not exist.

# mkdir spec/support
# touch database_cleaner.rb
# paste code from here https://github.com/DatabaseCleaner/database_cleaner#rspec-with-capybara-example

# --- Previously
# rails app:update:bin
# bin/rails generate rspec:install

# if things go wrong then 
# bundle binstubs rspec-core

# run tests

rspec

# bin/rails generate rspec:feature <feature_name>

require 'rails_helper'
# page.save_screenshot()
RSpec.feature "Visitor orders a product", type: :feature, js: true do

  scenario "They complete an order while logged in" do
    visit '/login'
  
    within 'form' do
      fill_in id: 'email', with: 'first@user.com'
      fill_in id: 'password', with: '123456'
  
      click_button 'Submit'
    end
  
    it{ expect(page).to have_content 'Thank you for your order first@user.com!' }
  end

  before :each do
    @user = User.create!(
      name: 'First User',
      email: 'first@user.com',
      password: '123456',
      password_confirmation: '123456'
    )

    @category = Category.create! name: 'Apparel'
    @category.products.create!(
      name: 'Cool Shirt',
      description: 'A really cool shirt.',
      image: 'test.jpg',
      quantity: 3,
      price: 12.99
    )
  end

  def add_product_and_checkout
    visit '/'
    # Find a product/first product within that product click the button with add
    # page change
    first('article.product').find_button('Add').click
    
    # checking if the Nav UI is updated (1)
    #Clicking on the cart nav button
    find_link('My Cart (1)').click

    # check if new cart page has product
    expect(page).to have_content "TOTAL:"
    expect(page).to have_content "Nividia 3800"

    page.save_screenshot
  end

  scenario "They complete an order while not logged in" do
    visit root_path
  
    add_product_and_checkout
  
    it{ expect(page).to have_content 'Thank you for your order!'  }
  end


end