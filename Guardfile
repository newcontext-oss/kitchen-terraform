# frozen_string_literal: true

require "guard/rspec/dsl"

directories ["lib", "spec"]

group :red_green_refactor, halt_on_fail: true do
  ::Guard::RSpec::Dsl.new(self).tap do |dsl|
    guard :rspec, all_after_pass: true, all_on_start: true, bundler_env: :inherit, cmd: "bundle exec rspec" do
      watch dsl.rspec.spec_files

      watch dsl.rspec.spec_helper do dsl.rspec.spec_dir end

      watch dsl.rspec.spec_support do dsl.rspec.spec_dir end

      dsl.watch_spec_files_for dsl.ruby.lib_files
    end

    guard :rubocop, all_on_start: true do
      watch dsl.rspec.spec_files

      watch dsl.rspec.spec_helper

      watch dsl.rspec.spec_support

      watch dsl.ruby.lib_files
    end

    guard "rubycritic" do
      watch dsl.rspec.spec_files

      watch dsl.rspec.spec_helper

      watch dsl.rspec.spec_support

      watch dsl.ruby.lib_files
    end
  end

  guard :bundler do watch "kitchen-terraform.gemspec" end

  guard :bundler_audit, run_on_start: true do watch "Gemfile.lock" end
end
