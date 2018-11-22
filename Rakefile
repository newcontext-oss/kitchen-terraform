# frozen_string_literal: true

namespace :test do
  begin
    require "rspec/core/rake_task"
    ::RSpec::Core::RakeTask.new :spec
  rescue ::LoadError
    puts "The gem named rspec is not available"
  end
  begin
    require "tty/which"
    if ::TTY::Which.exist? "terraform"
      begin
        require "kitchen/rake_tasks"
        ::Kitchen::RakeTasks.new
      rescue ::LoadError
        puts "The gem named test-kitchen is not available"
      end
    end
  rescue ::LoadError
    puts "The gem named tty-which is not available"
  end
end

task default: "test:spec"
