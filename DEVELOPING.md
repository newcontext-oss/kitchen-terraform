# Developing

## Significant Project Technologies

Familiarity with the following technologies is important in
understanding the design and behaviour of Kitchen-Terraform.

- [Ruby](https://www.ruby-lang.org/en/)
- [Test Kitchen](http://kitchen.ci/)
- [Terraform](https://www.terraform.io/)
- [Inspec](https://www.inspec.io/)

## Unit Testing

[RSpec](http://rspec.info/) is used as the unit testing framework.
The unit tests can be executed by running [`bin/rspec`](bin/rspec).
[.rspec](.rspec) contains command line options which will be
automatically applied.
[spec/spec_helper.rb](spec/spec_helper.rb) cotains framework
configuration.
The files under [spec/lib](spec/lib) contain the executable descriptions
of the units.
The files under [spec/support](spec/support) contain supporting logic
like shared examples and shared contexts.

## Integration Testing

The
[Terraform Docker provider](https://www.terraform.io/docs/providers/docker/index.html)
is used to run integration tests against a real Terraform state.
The Terraform module under
[integration/docker_provider](integration/docker_provider) includes
Kitchen-Terraform configuration and an InSpec profile used to verify
features of Kitchen-Terraform.

## Download, Install and run tests

1. Clone the kitchen-terraform repository:
   `git clone git@github.com:newcontext-oss/kitchen-terraform.git`
1. Download and install the [required dependencies]
1. Run `bundle install`
1. In a separate terminal you can run `bundle exec guard`
1. Please get familiar with [the tests] and features
1. Begin coding!

[the tests]: spec/lib
[required depedencies]: README.md#requirements

### Notes

Tests can be run manually by doing: `bundle exec rspec`
Style checks can be run manually by doing:
`bundle exec rubocop --format clang`
