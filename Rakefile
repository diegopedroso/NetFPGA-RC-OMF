require "bundler/setup"
require 'rake/testtask'
require "bundler/gem_tasks"

task :default => :test

Rake::Task[:release].clear

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/**/*_spec.rb"
  t.verbose = true
end
