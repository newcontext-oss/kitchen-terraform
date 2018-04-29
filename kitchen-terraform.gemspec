# frozen_string_literal: true

::File
  .expand_path("../lib", __FILE__)
  .tap do |directory|
    $LOAD_PATH.include? directory or $LOAD_PATH.unshift directory
  end

require "kitchen/terraform/version.rb"
require "rubygems"
version = ::Kitchen::Terraform::Version.new

::Gem::Specification.new do |specification|
  specification
    .authors = [
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
      "Walter Dolce",
      "curleighbraces"
    ]

  specification.description = "kitchen-terraform is a set of Test Kitchen plugins for testing Terraform configuration"

  specification.files = ::Dir.glob "{lib/**/*.rb,LICENSE,README.md}"

  specification.name = "kitchen-terraform"

  specification.summary = "Test Kitchen plugins for testing Terraform configuration"

  version.assign_specification_version specification: specification

  specification.email = "kitchen-terraform@newcontext.com"

  specification.homepage = "https://github.com/newcontext-oss/kitchen-terraform"

  specification.license = "Apache-2.0"

  specification
    .add_development_dependency(
      "bundler-audit",
      "~> 0.6.0"
    )

  specification.add_development_dependency "guard", "~> 2.14"

  specification.add_development_dependency "guard-bundler", "~> 2.1"

  specification
    .add_development_dependency(
      "guard-bundler-audit",
      "~> 0.1.4"
    )

  specification.add_development_dependency "guard-rspec", "~> 4.7"

  specification.add_development_dependency "guard-yard", "~> 2.2"

  specification
    .add_development_dependency(
      "middleman",
      "~> 4.2"
    )

  specification
    .add_development_dependency(
      "middleman-autoprefixer",
      "~> 2.7"
    )

  specification
    .add_development_dependency(
      "middleman-favicon-maker",
      "~> 4.1"
    )

  specification
    .add_development_dependency(
      "middleman-livereload",
      "~> 3.4"
    )

  specification
    .add_development_dependency(
      "middleman-syntax",
      "~> 3.0"
    )

  specification
    .add_development_dependency(
      "mini_racer",
      "~> 0.1.0"
    )

  specification.add_development_dependency "pry", "~> 0.10"

  specification.add_development_dependency "pry-coolline", "~> 0.2"

  specification
    .add_development_dependency(
      "rake",
      "~> 12.3"
    )

  specification.add_development_dependency "rspec", "~> 3.4"

  specification
    .add_development_dependency(
      "rubyzip",
      "~> 1.2"
    )

  specification
    .add_development_dependency(
      "simplecov",
      "~> 0.16.1"
    )

  specification.add_development_dependency "travis", "~> 1.8"

  specification.add_development_dependency "yard", "~> 0.9"

  specification.add_runtime_dependency "dry-types", "~> 0.9"

  specification.add_runtime_dependency "dry-validation", "~> 0.10"

  specification.add_runtime_dependency "kitchen-inspec", "~> 0.18"

  specification.add_runtime_dependency "mixlib-shellout", "~> 2.2"

  specification.cert_chain = ["certs/gem-public_cert.pem"]

  specification.requirements = ["Terraform >= 0.10.2, < 0.12.0"]

  specification.signing_key = "certs/gem-private_key.pem"

  version
    .if_satisfies requirement: ::Gem::Requirement.new("~> 3.3") do
      specification
        .add_runtime_dependency(
          "test-kitchen",
          "~> 1.16"
        )

      ::Kitchen::Terraform::Version
        .new(version: ::RUBY_VERSION)
        .if_satisfies requirement: ::Gem::Requirement.new("~> 2.2.0") do
          # rubocop:disable Gemspec/RedundantParentheses, Layout/SpaceAroundOperators
          specification
            .post_install_message=(
              "DEPRECATING: the current version of Ruby is #{::RUBY_VERSION}; this version will not be supported in " \
                "an upcoming major release of Kitchen-Terraform"
            )
          # rubocop:enable Gemspec/RedundantParentheses, Layout/SpaceAroundOperators
        end

      specification.required_ruby_version =
        [
          ">= 2.2",
          "< 2.6"
        ]
    end

  version
    .if_satisfies requirement: ::Gem::Requirement.new(">= 4") do
      specification
        .add_runtime_dependency(
          "test-kitchen",
          "~> 1.20"
        )

      # rubocop:disable Gemspec/DuplicatedAssignment
      specification.required_ruby_version =
        [
          ">= 2.3",
          "< 2.6"
        ]
      # rubocop:enable Gemspec/DuplicatedAssignment
    end
end
