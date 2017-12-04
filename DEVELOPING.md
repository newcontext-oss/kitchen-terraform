# Developing

## Reviewing Significant Project Technologies

Familiarity with the following technologies is important in
understanding the design and behaviour of Kitchen-Terraform.

- [Ruby](https://www.ruby-lang.org/en/)
- [Test Kitchen](http://kitchen.ci/)
- [Terraform](https://www.terraform.io/)
- [Inspec](https://www.inspec.io/)

## Obtaining Source Code

[Git](https://git-scm.com/) is used to manage the source code.

Running
`git clone https://github.com/newcontext-oss/kitchen-terraform.git` will
clone this repository to the current working directory.

## Unit Testing

[RSpec](http://rspec.info/) is used as the unit testing framework.

The unit tests can be executed by running [`bin/rspec`](bin/rspec).

[.rspec](.rspec) contains command line options which will be
automatically applied.

[spec/spec_helper.rb](spec/spec_helper.rb) contains framework
configuration.

The files under [spec/lib](spec/lib) contain the executable descriptions
of the units.

The files under [spec/support](spec/support) contain supporting logic
like shared examples and shared contexts.

[Guard](http://guardgem.org/) can be used to automate the execution of
unit tests during the development process.

Running [`bin/guard`](bin/guard) will start the process to detect file
changes and run appropriate unit tests.

## Integration Testing

The
[Terraform Docker provider](https://www.terraform.io/docs/providers/docker/index.html)
is used to run integration tests against a real Terraform state.

The Terraform module under
[integration/docker_provider](integration/docker_provider) includes
Kitchen-Terraform configuration and an InSpec profile used to verify
features of Kitchen-Terraform.




