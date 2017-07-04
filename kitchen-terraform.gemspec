# frozen_string_literal: true

::File.expand_path("../lib", __FILE__)
      .tap do |directory| $LOAD_PATH.unshift directory unless $LOAD_PATH.include? directory end

require "terraform/project_version.rb"

::Gem::Specification.new do |specification|
  specification.authors = [
    "Aaron Lane",
    "Clay Thomas",
    "David Begin",
    "Erik R. Rygg",
    "Ewa Czechowska",
    "John Engelman",
    "Kevin Dickerson",
    "Kyle Sexton",
    "Matt Long",
    "Michael Glenney",
    "Nell Shamrell-Harrington",
    "Nick Willever",
    "Steven A. Burns",
    "Walter Dolce"
  ]

  specification.files = ::Dir.glob "{lib/**/*.rb,LICENSE,README.md}"

  specification.name = "kitchen-terraform"

  specification.summary = "Test Kitchen plugins for testing Terraform projects"

  specification.version = ::Terraform::PROJECT_VERSION

  specification.email = "kitchen-terraform@newcontext.com"

  specification.homepage = "https://github.com/newcontext-oss/kitchen-terraform"

  specification.license = "Apache-2.0"

  specification.add_development_dependency "bundler-audit", "~> 0.5"

  specification.add_development_dependency "codeclimate-test-reporter", "~> 1.0"

  specification.add_development_dependency "guard", "~> 2.14"

  specification.add_development_dependency "guard-bundler", "~> 2.1"

  specification.add_development_dependency "guard-bundler-audit", "~> 0.1"

  specification.add_development_dependency "guard-rspec", "~> 4.7"

  specification.add_development_dependency "guard-rubocop", "~> 1.2"

  specification.add_development_dependency "guard-rubycritic", "~> 2.9"

  specification.add_development_dependency "guard-yard", "~> 2.2"

  specification.add_development_dependency "pry", "~> 0.10"

  specification.add_development_dependency "pry-coolline", "~> 0.2"

  specification.add_development_dependency "rspec", "~> 3.4"

  specification.add_development_dependency "rubocop", "~> 0.40"

  specification.add_development_dependency "travis", "~> 1.8"

  specification.add_development_dependency "yard", "~> 0.9"

  specification.add_runtime_dependency "dry-monads", "~> 0.3"

  specification.add_runtime_dependency "dry-types", "~> 0.9"

  specification.add_runtime_dependency "dry-validation", "~> 0.10"

  specification.add_runtime_dependency "kitchen-inspec", "~> 0.18"

  specification.add_runtime_dependency "mixlib-shellout", "~> 2.2"

  specification.add_runtime_dependency "test-kitchen", "~> 1.10"

  specification.cert_chain = ["certs/public_cert.pem"]

  specification.required_ruby_version = [">= 2.2", "< 2.5"]

  specification.requirements = ["Terraform >= 0.7, < 0.10"]

  specification.signing_key = "certs/private_key.pem"
end
