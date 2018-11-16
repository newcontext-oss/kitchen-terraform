# frozen_string_literal: true

require "bundler/gem_tasks"
require "kitchen/rake_tasks"
require "tty/which"

namespace :test do
  ::Kitchen::RakeTasks.new if ::TTY::Which.exist? "terraform"
end

task default: "test:kitchen:all"
