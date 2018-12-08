# frozen_string_literal: true

namespace :test do
  begin
    require "rspec/core/rake_task"
    ::RSpec::Core::RakeTask.new :spec
  rescue ::LoadError
    puts "The gem named rspec is not available"
  end
  begin
    require "kitchen/rake_tasks"
    ::Kitchen::RakeTasks.new
  rescue ::Kitchen::UserError
    puts "Terraform is not available; omitting Kitchen tasks"
  rescue ::LoadError
    puts "The gem named test-kitchen is not available"
  end
end

task default: "test:spec"
