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
  rescue ::Kitchen::UserError => user_error
    puts "Terraform is not available; omitting Kitchen tasks", user_error, ""
  rescue ::LoadError => load_error
    puts "The gem named test-kitchen is not available", load_error, ""
  rescue ::NameError => name_error
    puts "kitchen/rake_tasks is not compatible with this version of Ruby", name_error, ""
  end
end

task default: "test:rspec"
