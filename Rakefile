# frozen_string_literal: true

require "kitchen/rake_tasks"
require "rspec/core/rake_task"
require "tty/which"

namespace :test do
  ::Kitchen::RakeTasks.new if ::TTY::Which.exist? "terraform"

  ::RSpec::Core::RakeTask.new :rspec do |task|
    task.rspec_opts = "--backtrace"
  end
end

task default: "test:rspec"
