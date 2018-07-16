source 'https://rubygems.org'
git_source :github do |repo|
  "https://github.com/#{repo}.git"
end

gemspec

gem 'rom', github: 'rom-rb/rom', branch: 'master'

group :test do
  gem 'rspec', '~> 3.1'
  gem 'codeclimate-test-reporter', require: false
end

group :tools do
  gem 'rubocop', '~> 0.28.0'
end
