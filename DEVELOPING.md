# Developing on kitchen-terraform

## Get familiar with the technologies this project uses:

- [Test Kitchen]
- [Terraform]
- [Inspec]

[Test Kitchen]: http://kitchen.ci
[Terraform]: https://www.terraform.io
[Inspec]: https://github.com/chef/inspec

## Download, Install and run tests

1. Clone the kitchen-terraform repository: `git clone git@github.com:newcontext/kitchen-terraform.git`
2. Download and install the [required dependencies]
3. Run `bundle install --trust-policy MediumSecurity`
3. In a separate terminal you can run `bundle exec guard`
4. Please get familiar with [the tests] and features
5. Begin coding!

[the tests]: spec/lib
[required depedencies]: README.md#requirements

### Notes

Tests can be run manually by doing: `bundle exec rspec`
Style checks can be run manually by doing: `bundle exec rubocop --format clang`