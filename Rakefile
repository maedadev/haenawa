# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'ci/reporter/rake/minitest'

Rails.application.load_tasks

namespace :test do
  Rails::TestTask.new('jobs' => 'test:prepare') do |t|
    t.pattern = "test/jobs/**/*_test.rb"
  end
end

Rake::Task['test:run'].enhance ['test:jobs']
