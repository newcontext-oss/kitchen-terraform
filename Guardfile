# frozen_string_literal: true

directories ["lib", "spec"]

group :red_green_refactor, halt_on_fail: true do
  guard :yard, cli: "--reload" do
    watch /lib\/.+\.rb/
  end

  guard(
    :rspec,
    all_after_pass: true,
    all_on_start: true,
    bundler_env: :inherit,
    cmd: "bundle exec rspec",
    failure_mode: :focus,
  ) do
    require "guard/rspec/dsl"
    dsl = Guard::RSpec::Dsl.new self 
  
    # RSpec files
    rspec = dsl.rspec
    watch rspec.spec_helper do 
      rspec.spec_dir
    end
    watch rspec.spec_support do
      rspec.spec_dir
    end
    watch rspec.spec_files
  
    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for ruby.lib_files
  end
end
