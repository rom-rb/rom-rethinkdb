# encoding: utf-8

require 'bundler'
Bundler.require

if RUBY_ENGINE == 'rbx'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'rom-rethinkdb'

require_relative 'support/prepare_db'

RSpec.configure do |config|
  include PrepareDB

  config.before(:suite) do
    create_database('test_db')
    create_table('test_db', 'users')
  end

  config.after(:suite) do
    drop_database('test_db')
  end
end

ROM.use :auto_registration
