require 'rake/testtask'

namespace :test do
  desc 'Run connector tests'
  Rake::TestTask.new(:connectors) do |t|
    t.libs << 'test'
    t.pattern = 'connectors/**/test/**/*_test.rb'
  end
end

Rake::Task['test'].enhance ['test:connectors']
