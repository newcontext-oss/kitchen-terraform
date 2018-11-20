# frozen_string_literal: true

require "guard/rspec/dsl"

directories ["lib", "spec"]

group :red_green_refactor, halt_on_fail: true do
  ::Guard::RSpec::Dsl.new(self).tap do |dsl|
    guard :bundler do
      watch "kitchen-terraform.gemspec"
    end

    guard :yard, cli: "--reload" do
      watch /lib\/.+\.rb/
    end

    guard(
      :rspec,
      all_after_pass: true,
      all_on_start: true,
      cmd: "bundle exec rspec",
      failure_mode: :focus,
    ) do
      watch dsl.rspec.spec_files

      watch dsl.rspec.spec_helper do dsl.rspec.spec_dir end

      watch dsl.rspec.spec_support do dsl.rspec.spec_dir end

      dsl.watch_spec_files_for dsl.ruby.lib_files
    end
  end
end
