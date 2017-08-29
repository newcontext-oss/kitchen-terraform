# ![kitchen-terraform logo](assets/logo.png) kitchen-terraform

[![Gem Version](https://badge.fury.io/rb/kitchen-terraform.svg)](https://badge.fury.io/rb/kitchen-terraform)
[![Code Climate](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/badges/gpa.svg)](https://codeclimate.com/github/newcontext-oss/kitchen-terraform)
[![Issue Count](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/badges/issue_count.svg)](https://codeclimate.com/github/newcontext-oss/kitchen-terraform)
[![Build Status Master](https://travis-ci.org/newcontext-oss/kitchen-terraform.svg?branch=master)](https://travis-ci.org/newcontext-oss/kitchen-terraform)
[![Test Coverage](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/badges/coverage.svg)](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/coverage)

kitchen-terraform is a set of [Test Kitchen] plugins for testing
[Terraform configuration].

## Requirements

- [Ruby] **(~> 2.2)**

- [Bundler] **(~> 1.12)**

- [Terraform] **(~> 0.10.2)**

## Installation

kitchen-terraform is packaged as a cryptographically signed [Ruby gem]
which means it can be [installed with Bundler].

### Adding kitchen-terraform to a Terraform project

Once Bundler is installed, add kitchen-terraform to the project's
Gemfile:

```rb
source "https://rubygems.org/" do
  gem "kitchen-terraform", "~> 1.0"
end
```

Then, use Bundler to install the gems:

```sh
bundle install
```

## Usage

kitchen-terraform provides three Test Kitchen plugins which must be used
together in the [Test Kitchen configuration] in order to successfully
test Terraform configuration:

- a [driver] that creates and destroys [Terraform state];

- a [provisioner] that applies changes to existing Terraform state;

- a [verifier] that verifies the state and behaviour of resources in the
  Terraform state.

Refer to the [gem documentation] for more information about
kitchen-terraform's design and behaviour.

Refer to the [Getting Started README] for a detailed walkthrough of
setting up and using kitchen-terraform.

Refer to the [examples directory] for example Terraform projects using
various [Terraform providers].

[Bundler]: https://bundler.io/index.html
[Getting Started README]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/examples/aws_provider/getting_started.md
[Ruby Gem]: http://guides.rubygems.org/what-is-a-gem/index.html
[Ruby]: https://www.ruby-lang.org/en/index.html
[Terraform configuration]: https://www.terraform.io/docs/configuration/index.html
[Terraform providers]: https://www.terraform.io/docs/configuration/providers.html
[Terraform state]: https://www.terraform.io/docs/state/index.html
[Terraform]: https://www.terraform.io/index.html
[Test Kitchen configuration]: https://docs.chef.io/config_yml_kitchen.html
[Test Kitchen]: http://kitchen.ci/index.html
[driver]: http://www.rubydoc.info/gems/kitchen-terraform/Kitchen/Driver/Terraform
[examples directory]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/examples
[gem documentation]: http://www.rubydoc.info/gems/kitchen-terraform/index
[installed with Bundler]: https://bundler.io/index.html#getting-started
[provisioner]: http://www.rubydoc.info/gems/kitchen-terraform/Kitchen/Provisioner/Terraform
[verifier]: http://www.rubydoc.info/gems/kitchen-terraform/Kitchen/Verifier/Terraform
