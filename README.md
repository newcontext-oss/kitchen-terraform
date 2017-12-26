# ![kitchen-terraform logo](assets/logo.png) kitchen-terraform

[![Gem Version](https://badge.fury.io/rb/kitchen-terraform.svg)](https://badge.fury.io/rb/kitchen-terraform)
[![Code Climate](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/badges/gpa.svg)](https://codeclimate.com/github/newcontext-oss/kitchen-terraform)
[![Issue Count](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/badges/issue_count.svg)](https://codeclimate.com/github/newcontext-oss/kitchen-terraform)
[![Build Status Master](https://travis-ci.org/newcontext-oss/kitchen-terraform.svg?branch=master)](https://travis-ci.org/newcontext-oss/kitchen-terraform)
[![Test Coverage](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/badges/coverage.svg)](https://codeclimate.com/github/newcontext-oss/kitchen-terraform/coverage)
[![Join the chat at https://gitter.im/kitchen-terraform](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/kitchen-terraform)

kitchen-terraform is a set of
[Test Kitchen](http://kitchen.ci/index.html) plugins for testing
[Terraform configuration](https://www.terraform.io/docs/configuration/index.html)
.

## Requirements

- [Ruby](https://www.ruby-lang.org/en/index.html) **(~> 2.2)**

- [Bundler](https://bundler.io/index.html) **(~> 1.12)**

- [Terraform](https://www.terraform.io/index.html)
  **(>= 0.10.2, < 0.12.0)**

## Installation

kitchen-terraform is packaged as a cryptographically signed
[Ruby gem](http://guides.rubygems.org/what-is-a-gem/index.html) which
means it can be
[installed with Bundler](https://bundler.io/index.html#getting-started).

### Adding kitchen-terraform to a Terraform project

Once Bundler is installed, add kitchen-terraform to the project's
Gemfile:

```rb
source "https://rubygems.org/" do
  gem "kitchen-terraform", "~> 3.0"
end
```

Then, use Bundler to install the gems:

```sh
bundle install
```

## Usage

kitchen-terraform provides three Test Kitchen plugins which must be used
together in the
[Test Kitchen configuration](https://docs.chef.io/config_yml_kitchen.html)
in order to successfully test Terraform configuration:

- a [driver](http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Driver/Terraform)
  that creates and destroys
  [Terraform state](https://www.terraform.io/docs/state/index.html);

- a [provisioner](http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Provisioner/Terraform)
  that applies changes to existing Terraform state;

- a [verifier](http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Verifier/Terraform)
  that verifies the state and behaviour of resources in the Terraform
  state.

Refer to the [gem documentation](http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/)
for more information about kitchen-terraform's design and behaviour.

Refer to the
[Getting Started Tutorial](https://newcontext-oss.github.io/kitchen-terraform/tutorials/amazon_provider_ec2.html)
for a detailed walkthrough of setting up and using kitchen-terraform.

Refer to the
[tutorials](https://newcontext-oss.github.io/kitchen-terraform/tutorials)
for example Terraform projects using various
[Terraform providers](https://www.terraform.io/docs/configuration/providers.html)
.


### With docker
Please note that when running in docker, some tests that themselves use docker
Can have issues connecting if you use the `-v /var/run/docker.sock:/var/run/docker.sock` way to have the image start docker images.

You'll need to mount in your credentials with either environment
variables or your credentials file.  The default working directory is workspace, and you'll want to mount that in.  

The command is passed into  the `kitchen` command, so you can
give a command of `converge`, `verify`, `test` etc. 

You can build it yourself with a 
`docker build . -t kitchen-terraform`


e.g. 
`docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
   -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
   -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
   -v $(pwd):/workspace kitchen-terraform test` or

or if you're using credentials files and have a aws profile
called personal, you could do:
`docker run --rm -v $(pwd):/workspace \
   -v ~/.aws/:/root/.aws:ro  \
   -e AWS_PROFILE=$AWS_PROFILE \
  kitchen-terraform test`