# frozen_string_literal: true

namespace :test do
  begin
    require "rspec/core/rake_task"
    ::RSpec::Core::RakeTask.new :rspec
  rescue ::LoadError
    puts "The gem named rspec is not available"
  end
  begin
    require_relative "test/kitchen/terraform/rake_tasks"
    ::Test::Kitchen::Terraform::RakeTasks.new
  rescue ::Kitchen::UserError
    puts "Terraform is not available; omitting Kitchen tasks"
  rescue ::LoadError
    puts "The gem named test-kitchen is not available"
  end
end

task default: "test:rspec"
