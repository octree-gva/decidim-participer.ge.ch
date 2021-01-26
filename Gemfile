# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", path: ".."
gem "decidim-consultations", path: ".."
gem "decidim-verifications", path: ".."


gem 'bootsnap', '~> 1.5', '>= 1.5.1'

gem 'puma', '~> 5.1', '>= 5.1.1'
gem 'uglifier', '~> 4.2'
gem 'faker', '~> 2.15', '>= 2.15.1'

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", path: ".."
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
