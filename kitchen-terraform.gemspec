# frozen_string_literal: true

::File.expand_path("../lib", __FILE__).tap do |directory|
  $LOAD_PATH.include? directory or $LOAD_PATH.unshift directory
end

require "kitchen/terraform/version.rb"
require "rubygems"

::Gem::Specification.new do |specification|
  specification.authors = ["Aaron Lane", "Nick Willever", "Kevin Dickerson", "Nell Shamrell-Harrington",
                           "Michael Glenney", "Walter Dolce", "Clay Thomas", "Erik R. Rygg", "Kyle Sexton",
                           "Ewa Czechowska", "Matt Long", "John Engelman", "Steven A. Burns", "David Begin",
                           "curleighbraces", "Austin Heiman", "Gary Foster"]
  specification.description = "kitchen-terraform is a set of Test Kitchen plugins for testing Terraform configuration"
  specification.files = ::Dir.glob "{lib/**/*.rb,LICENSE,README.md}"
  specification.name = "kitchen-terraform"
  specification.summary = "Test Kitchen plugins for testing Terraform configuration"
  ::Kitchen::Terraform::Version.assign_specification_version specification: specification
  specification.email = "kitchen-terraform@newcontext.com"
  specification.homepage = "https://newcontext-oss.github.io/kitchen-terraform/"
  specification.license = "Apache-2.0"
  specification.add_development_dependency "bundler", "~> 2.1"
  specification.add_development_dependency "rake", "~> 13.0"
  specification.add_development_dependency "rspec", "~> 3.4"
  specification.add_development_dependency "simplecov", "~> 0.16.1"
  specification.add_runtime_dependency "dry-validation", "~> 0.13"
  specification.add_runtime_dependency "inspec", ">= 3", "< 5"
  specification.add_runtime_dependency "json", "~> 2.2"
  specification.add_runtime_dependency "mixlib-shellout", "~> 3.0"
  specification.add_runtime_dependency "test-kitchen", "~> 2.1"
  specification.add_runtime_dependency "tty-which", "~> 0.4.0"

  specification.cert_chain = ["certs/gem-public_cert.pem"]
  specification.required_ruby_version = [">= 2.4", "< 2.7"]
  specification.requirements = ["Terraform >= v0.11.4, < v0.13.0"]
  specification.signing_key = "certs/gem-private_key.pem" if $PROGRAM_NAME =~ /gem\z/
end
