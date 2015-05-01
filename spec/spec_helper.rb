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
  config.include PrepareDB

  config.before(:all) do
    create_database('test_db')
  end

  config.after(:all) do
    drop_database('test_db')
  end
end
