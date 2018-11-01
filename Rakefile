# frozen_string_literal: true

require "kitchen/rake_tasks"
require "rspec/core/rake_task"
require "tty/which"

namespace :test do
  if TTY::Which.exist? "terraform"
    ::Kitchen::RakeTasks.new do
      ::ENV.store "KITCHEN_LOG", "debug"
      ::Kitchen.logger = ::Kitchen.default_logger
    end
  end

  ::RSpec::Core::RakeTask.new :rspec do |task|
    task.rspec_opts = "--backtrace"
  end
end

task default: "test:rspec"
