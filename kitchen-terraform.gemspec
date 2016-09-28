# frozen_string_literal: true

File.expand_path('../lib', __FILE__).tap do |directory|
  $LOAD_PATH.unshift directory unless $LOAD_PATH.include? directory
end

require 'terraform/version.rb'

Gem::Specification.new do |specification|
  specification.authors = [
    'Aaron Lane', 'Kevin Dickerson', 'Nell Shamrell-Harrington', 'Nick Willever'
  ]

  specification.files = Dir.glob '{lib/**/*.rb,LICENSE,README.md}'

  specification.name = 'kitchen-terraform'

  specification.summary = 'Test Kitchen plugins for testing Terraform projects'

  specification.version = Terraform::VERSION

  specification.email = 'kitchen-terraform@newcontext.com'

  specification.homepage = 'https://github.com/newcontext/kitchen-terraform'

  specification.license = 'Apache-2.0'

  specification.add_development_dependency 'bundler-audit', '~> 0.5', '>= 0.5.0'

  specification.add_development_dependency 'guard', '~> 2.14', '>= 2.14.0'

  specification.add_development_dependency 'guard-rspec', '~> 4.7', '>= 4.7.2'

  specification.add_development_dependency 'guard-rubocop', '~> 1.2', '>= 1.2.0'

  specification.add_development_dependency 'pry', '~> 0.10', '>= 0.10.3'

  specification.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'

  specification.add_development_dependency 'rubocop', '~> 0.40', '>= 0.40.0'

  specification.add_development_dependency 'simplecov', '~> 0.11', '>= 0.11.2'

  specification.add_runtime_dependency 'inspec', '~> 1.0'

  specification.add_runtime_dependency 'kitchen-inspec', '~> 0.14', '>= 0.14.0'

  specification.add_runtime_dependency 'mixlib-shellout', '~> 2.2', '>= 2.2.6'

  specification.add_runtime_dependency 'test-kitchen', '~> 1.10', '>= 1.10.0'

  specification.cert_chain = ['certs/ncs-alane-public_cert.pem']

  specification.required_ruby_version = ['~> 2.3', '>= 2.3.1']

  specification.required_rubygems_version = ['~> 2.6', '>= 2.6.3']

  specification.requirements = ['Terraform >= 0.6.0, < 0.8.0']

  specification.signing_key =
    File.expand_path '~/.gem/ncs-alane-private_key.pem'
end
