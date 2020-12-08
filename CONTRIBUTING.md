# Contributing to Kitchen-Terraform

This document describes how to contribute to Kitchen-Terraform.
Proposals for changes to this document are welcome.

## Table of Contents

[Code of Conduct](#code-of-conduct)

[Asking Questions](#asking-questions)

[Project Technologies](#project-technologies)

## Code of Conduct

Contributors to Kitchen-Terraform are expected to adhere to the
[Kitchen-Terraform Code of Conduct](CODE_OF_CONDUCT.md). Any
unacceptable conduct should be reported to
kitchen-terraform@newcontext.com.

## Questions

Questions about the project may be posed on the
[GitHub issue tracker][github-issue-tracker] or in the
[Gitter chat][gitter-chat].

## Project Technologies

Familiarity with the following technologies is important in
understanding the design and behaviour of Kitchen-Terraform.

- [Ruby][ruby]
- [Kitchen][kitchen]
- [Terraform][terraform]
- [InSpec][inspec]

## Reporting Bugs

Bugs must be reported on the
[GitHub issue tracker](github-issue-tracker). Any information that will
assist in the maintainers reproducing the bug should be included.

## Suggesting Changes

Changes should be suggested on the
[GitHub issue tracker](github-issue-tracker). Submitting a pull request
with an implementation of the changes is also encouraged but not
required.

## Developing

The development workflow for both the Kitchen-Terraform Ruby gem and the
documentation web site follow the same
[standard GitHub workflow](fork-a-repo).

### Ruby Gem

#### Unit Testing

[RSpec][rspec] is used as the unit testing framework.

[Rake][rake] is used to orchestrate the unit tests.

The following command will execute the unit tests.

> Executing unit tests with RSpec

```sh
bundle exec rake test:spec
```

[.rspec](.rspec) contains command line options which will be
automatically applied.

[spec/spec_helper.rb](spec/spec_helper.rb) contains framework
configuration.

The files under [spec/lib](spec/lib) contain the executable descriptions
of the different units of the Ruby gem.

The files under [spec/support](spec/support) contain supporting logic
like shared examples and shared contexts.

[Guard][guard] can be used to automate the execution of unit tests
during the development process.

The following command will start the process to detect file changes and
run appropriate unit tests.

> Watching for file changes with Guard

```sh
bundle exec guard
```

#### Integration Testing

[Kitchen][kitchen], [Terraform][terraform], and [InSpec][inspec] are
used as the integration testing framework.

[Rake][rake] is used to orchestrate the integration tests.

The following command will execute the integration tests.

> Executing integration tests with Rake

```sh
bundle exec rake test:kitchen:all
```

[Rakefile](Rakefile) contains the task definitions.

The [Terraform Docker provider][terraform-docker-provider] is used to
run integration tests against a real Terraform state.

[integration/basic](integration/basic) includes Kitchen-Terraform
configuration and an InSpec profile used to verify the basic features of
Kitchen-Terraform.

Other directories under [integration](integration) are used to test the
handling of special cases.

#### Analyzing Code Quality

[Code Climate][code-climate] is used to analyze the quality of the
source code of the Ruby gem.

[.codeclimate.yml](.codeclimate.yml) contains analysis configuration.

A [command line interface][code-climate-cli] is available to run the
analysis locally.

#### Continuously Integrating and Continuously Deploying

[GitHub Actions][github-actions] are used to provide continuous integration and
continuous deployment functionality for the Ruby gem.

[tests.yml](.github/workflows/tests.yml) define unit and integration tests that will be executed for each commit to the master branch and each commit to a branch with an open pull request.

[release.yml](.github/workflows/release.yml) contains the job configuration to deploy the Ruby gem. If a [tag][git-tag] starting with v is pushed to the master branch, then the job will attempt to build the Ruby gem and deploy it to [RubyGems][ruby-gems].

#### Releasing

Changes will be committed to the master branch as they are completed.
When the goals of the next project milestone have been achieved, the
master branch will be tagged with a new version number which will
trigger a release of the Ruby gem.

### Web Site

The web site comprises documentation, examples, and tutorials for
working with Kitchen-Terraform.

The web site published on the master branch is hosted at
<https://newcontext-oss.github.io/kitchen-terraform/>.

#### Writing Content

The web site uses the [Middleman][middleman] framework.

The following command will run the Middleman server so that changes to
the content can be reviewed at <http://localhost:4567/>.

> Running Middleman server to review content changes

```sh
env NO_CONTRACTS=true bundle exec middleman server --build-dir docs
```

[config.rb](config.rb) contains Middleman configuration.

[source](source) contains the source files for the web site.

[docs](docs) contains the compiled web site.

#### Building Site

The following command will build an HTML site based on the Middleman
project.

> Building HTML site based on Middleman project

```sh
bundle exec middleman build --build-dir docs
```

<!-- Markdown links and image definitions -->
[code-climate-cli]: https://github.com/codeclimate/codeclimate
[code-climate]: https://codeclimate.com/github/newcontext-oss/kitchen-terraform/
[fork-a-repo]: https://help.github.com/articles/fork-a-repo/
[git-tag]: https://git-scm.com/book/en/v2/Git-Basics-Tagging
[github-issue-tracker]: https://github.com/newcontext-oss/kitchen-terraform/issues
[gitter-chat]: https://gitter.im/kitchen-terraform/Lobby
[guard]: http://guardgem.org/
[inspec]: https://github.com/chef/inspec/tree/v1.44.8
[middleman]: https://middlemanapp.com/
[rake]: https://ruby.github.io/rake/
[rspec]: http://rspec.info/
[ruby-gems]: https://rubygems.org/gems/kitchen-terraform
[ruby]: https://www.ruby-lang.org/en/
[terraform-docker-provider]: https://www.terraform.io/docs/providers/docker/index.html
[terraform]: https://www.terraform.io/
[kitchen]: https://github.com/test-kitchen/test-kitchen/
[github-actions]: https://help.github.com/en/actions
