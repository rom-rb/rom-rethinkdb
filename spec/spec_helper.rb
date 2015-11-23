# encoding: utf-8

require 'bundler'
Bundler.require

if RUBY_ENGINE == 'rbx'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'rom-rethinkdb'

SPEC_ROOT = root = Pathname(__FILE__).dirname

Dir[root.join('support/*.rb').to_s].each do |f|
  require f
end
Dir[root.join('shared/*.rb').to_s].each do |f|
  require f
end

RSpec.configure do |config|
  config.include PrepareDB

  config.before(:suite) do
    PrepareDB.create_database('test_db')
  end

  config.after(:suite) do
    PrepareDB.drop_database('test_db')
  end
end
