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
                           "curleighbraces", "Austin Heiman", "Gary Foster", "Ed Bartholomew"]
  specification.description = "kitchen-terraform is a set of Test Kitchen plugins for testing Terraform configuration"
  specification.files = ::Dir.glob "{lib/**/*.rb,LICENSE,README.md}"
  specification.name = "kitchen-terraform"
  specification.summary = "Test Kitchen plugins for testing Terraform configuration"
  ::Kitchen::Terraform::Version.assign_specification_version specification: specification
  specification.email = "kitchen-terraform@newcontext.com"
  specification.homepage = "https://newcontext-oss.github.io/kitchen-terraform/"
  specification.license = "Apache-2.0"
  specification.add_development_dependency "guard-rspec", "~> 4.7"
  specification.add_development_dependency "guard-yard", "~> 2.2"
  specification.add_development_dependency "guard", "~> 2.14"
  specification.add_development_dependency "middleman-autoprefixer", "~> 2.7"
  specification.add_development_dependency "middleman-favicon-maker", "~> 4.1"
  specification.add_development_dependency "middleman-livereload", "~> 3.4"
  specification.add_development_dependency "middleman-syntax", "~> 3.0"
  specification.add_development_dependency "middleman", "~> 4.2"
  specification.add_development_dependency "rake", "~> 13.0"
  specification.add_development_dependency "rspec", "~> 3.10"
  specification.add_development_dependency "rufo", "~> 0.15.1"
  specification.add_development_dependency "simplecov", "~> 0.22.0"
  specification.add_development_dependency "yard", "~> 0.9"
  specification.add_development_dependency "reek", "~> 6.1"
  # webrick is implicitly required by yard
  specification.add_development_dependency "webrick", "~> 1.7"
  specification.add_runtime_dependency "delegate", "~> 0.3.0"
  specification.add_runtime_dependency "inspec", ">= 4.25.1", "< 6"
  specification.add_runtime_dependency "json", "~> 2.3"
  specification.add_runtime_dependency "test-kitchen", ">= 2.1", "< 4.0"
  specification.add_runtime_dependency "tty-which", "~> 0.5.0"
  specification.cert_chain = ["certs/gem-public_cert.pem"]
  specification.required_ruby_version = [">= 2.7", "< 4.0"]
  specification.requirements = ["Terraform >= v0.11.4, < v2.0.0"]
  specification.signing_key = "certs/gem-private_key.pem" if $PROGRAM_NAME =~ /gem\z/
end
