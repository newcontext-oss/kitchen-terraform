# Developing on kitchen-terraform

## Get familiar with the technologies this project uses

- [Test Kitchen]
- [Terraform]
- [Inspec]

[Test Kitchen]: http://kitchen.ci
[Terraform]: https://www.terraform.io
[Inspec]: https://github.com/chef/inspec

## Download, Install and run tests

1. Clone the kitchen-terraform repository:
   `git clone git@github.com:newcontext/kitchen-terraform.git`
1. Download and install the [required dependencies]
1. Run `bundle install --trust-policy MediumSecurity`
1. In a separate terminal you can run `bundle exec guard`
1. Please get familiar with [the tests] and features
1. Begin coding!

[the tests]: spec/lib
[required depedencies]: README.md#requirements

### Notes

Tests can be run manually by doing: `bundle exec rspec`
Style checks can be run manually by doing:
`bundle exec rubocop --format clang`
