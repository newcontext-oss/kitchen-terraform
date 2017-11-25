# kitchen-terraform documentation

[kitchen-terraform] is a set of [Test Kitchen] plugins for testing
[Terraform configuration].

This is the documentation and examples for [kitchen-terraform]

[kitchen-terraform]: https://github.com/newcontext-oss/kitchen-terraform
[Terraform configuration]: https://www.terraform.io/docs/configuration/index.html
[Test Kitchen]: http://kitchen.ci/index.html

## Usage

This directory `<git root>/website` is the source files for the
middleman static website that is built in `<git root>/docs`

This is where you'll find the most current master branch documentation:
(https://newcontext-oss.github.io/kitchen-terraform/)

## Developing

### Install and Run middleman

```sh
bundle install
NO_CONTRACTS=true bundle exec middleman server
```

### Build and Deploy documentation

```sh
bundle exec middleman build --build-dir ../docs
# adding additional files makes sure to do a git add
git commit -a -v
```
