#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/clean'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

task default: :test

Rake::TestTask.new do |task|
  task.libs << 'lib'
  task.libs << 'spec'
  task.test_files = FileList['test/**/test*.rb','spec/**/*_spec.rb']
end
