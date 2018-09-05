source 'https://rubygems.org'

ruby '2.5.1'
gem 'bootsnap', '1.3.0'
gem 'breadcrumbs_on_rails'
gem 'chartkick'
gem 'devise'
gem 'jquery-rails'
gem 'kaminari-actionview'
gem 'kaminari-mongoid'
gem 'material_design_lite-sass'
gem 'mini_racer', platforms: :ruby
gem 'mongoid',    '7.0.1'
gem 'pdf-reader'
gem 'puma', '3.11.4'
gem 'pundit'
gem 'rails',      '5.2.0'
gem 'rollbar',    '~>2.16'
gem 'sass-rails', '5.0.7'
gem 'uglifier',   '4.1.10'
gem 'words_counted'

# JS goodies
source 'https://rails-assets.org' do
  gem 'rails-assets-jquery-minicolors'
  gem 'rails-assets-select2' # smarter select field
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rubocop'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # version from rubygems doesn't support mongoid 7
  gem 'mongoid-rspec', git: 'https://github.com/mongoid/mongoid-rspec.git'
  gem 'rspec-collection_matchers'
end
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
