# frozen_string_literal: true

group :red_green_refactor, halt_on_fail: true do
  require 'guard/rspec/dsl'

  Guard::RSpec::Dsl.new(self).tap do |dsl|
    guard :rspec, all_after_pass: true, all_on_start: true,
                  cmd: 'bundle exec rspec' do
      watch dsl.rspec.spec_files

      watch(dsl.rspec.spec_helper) { dsl.rspec.spec_dir }

      watch(dsl.rspec.spec_support) { dsl.rspec.spec_dir }

      dsl.watch_spec_files_for dsl.ruby.lib_files
    end

    guard :rubocop, all_on_start: true, cli: '--format clang' do
      watch dsl.rspec.spec_files

      watch dsl.rspec.spec_helper

      watch dsl.rspec.spec_support

      watch dsl.ruby.lib_files
    end
  end
end
