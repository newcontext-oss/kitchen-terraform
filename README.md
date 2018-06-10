# ![Kitchen-Terraform Logo][kitchen-terraform-logo] Kitchen-Terraform

> Kitchen-Terraform enables verification of Terraform state.

[![Gem version][gem-version-shield]][kitchen-terraform-gem]
[![Gem downloads version][gem-downloads-version-shield]][kitchen-terraform-gem]
[![Gem downloads total][gem-downloads-total-shield]][kitchen-terraform-gem]

[![Build status][build-status-shield]][build-status]
[![Test coverage][test-coverage-shield]][test-coverage]
[![Maintainability][maintainability-shield]][maintainability]
[![Dependencies][gemnasium-shield]][gemnasium]

[![Gitter chat][gitter-shield]][gitter]

Kitchen-Terraform provides a set of [Test Kitchen][test-kitchen] plugins
which enable a system to use Test Kitchen to converge a
[Terraform][terraform] configuration and verify the resulting Terraform
state with [InSpec][inspec] controls.

As Kitchen-Terraform integrates several distinctive technologies in a
nontrivial manner, reviewing the documentation of each of the
aforementioned products is strongly encouraged.

## Installation

### Terraform

Kitchen-Terraform integrates with the
[Terraform command-line interface][terraform-cli] to implement a Test
Kitchen workflow for Terraform modules.

Installation instructions can be found in the
[Terraform: Install Terraform][terraform-install] article.

Kitchen-Terraform supports versions of Terraform in the interval of
`>= 0.11.4, < 0.12.0`.

[tfenv] can be used to manage versions of Terraform on the system.

### Ruby

Kitchen-Terraform is written in [Ruby][ruby] which requires an
interpreter to be installed on the system.

Installation instructions can be found in the
[Ruby: Installing Ruby][ruby-installation] article.

Kitchen-Terraform aims to support all versions of Ruby that are in
["normal" or "security" maintenance][ruby-branches], which is currently
the interval of `>= 2.3, < 2.6`.

[rbenv] can be used to manage versions of Ruby on the system.

### Kitchen-Terraform Ruby Gem

Each version of Kitchen-Terraform is published as a
[Ruby gem][ruby-gems-what-is] to [RubyGems.org][kitchen-terraform-gem]
which makes them readily available for installation on a system.

#### Bundler

[Bundler][bundler] should be used to manage versions of
Kitchen-Terraform on the system. Using Bundler provides easily
reproducible Ruby gem installations that can be shared with other
systems.

First, create a `Gemfile` with contents like the following example. The
pessimistic pinning of the version is recommended to benefit from
the semantic versioning of the Ruby gem.

> Defining Kitchen-Terraform as a dependency for Bundler in a Gemfile

```ruby
source "https://rubygems.org/" do
  gem(
    "kitchen-terraform",
    "~> 3.1"
  )
end
```

Second, run the following command.

> Installing Kitchen-Terraform with Bundler

```sh
bundle install
```

The preceding command will create a `Gemfile.lock` comprising a list
of the resolved Ruby gem dependencies.

More information can be found in the
[Bundler: In Depth][bundler-in-depth] article.

#### RubyGems

RubyGems, the default Ruby package manager, can also be used to install
a version of Kitchen-Terraform by running a command like the following
example.

> Installing Kitchen-Terraform with RubyGems

```sh
gem install kitchen-terraform --version 3.1.0
```

This approach is not recommended as it requires more effort to install
the gem in a manner that is reproducible and free of dependency
conflicts.

More information can be found in the
[RubyGems: Installing Gems][rubygems-installing-gems] article.

## Usage

### Configuration

Kitchen-Terraform provides three Test Kitchen plugins which must be
configured in a
[Test Kitchen configuration file][test-kitchen-configuration-file] in
order to successfully test Terraform configuration.

The [Terraform driver][terraform-driver] manages the state of the
Terraform root module.

The [Terraform provisioner][terraform-provisioner] uses the Terraform
driver to apply changes to the Terraform state.

The [Terraform verifier][terraform-verifier] uses InSpec to verify the
Terraform state.

More information can be found in the
[Ruby gem documentation][ruby-gem-documentation].

### Example

This example demonstrates how to test a simple Terraform configuration
which utilizes the [Docker provider][docker-provider].

The test system is assumed to be running Ubuntu 17.04.

Terraform, Ruby, and Bundler are assumed to have been installed on the
test system as described in the [Installation](#installation) section.

The [Docker Community Edition][docker-community-edition] is assumed to
have been installed on the test system.

The working directory on the test system is assumed to contain a
hierarchy of files comprising the following blocks.

> Directory hierarchy

```
.
├── .kitchen.yml
├── Gemfile
├── main.tf
├── outputs.tf
└── test
    └── integration
        └── example
            ├── controls
            │   ├── operating_system.rb
            └── inspec.yml
```

> Gemfile

```ruby
source "https://rubygems.org/"

gem 'kitchen-terraform'
```

> ./.kitchen.yml (Test Kitchen configuration)

```yaml
driver:
  name: terraform

provisioner:
  name: terraform

transport:
  name: ssh
  password: root

verifier:
  name: terraform
  groups:
    - name: container
      hostnames: container_hostname
      port: 2222
      username: root

platforms:
  - name: ubuntu

suites:
  - name: example
```

> ./main.tf

```hcl
provider "docker" {
  host    = "unix://localhost/var/run/docker.sock"
}

data "docker_registry_image" "ubuntu" {
  name = "rastasheep/ubuntu-sshd:latest"
}

resource "docker_image" "ubuntu" {
  name          = "${data.docker_registry_image.ubuntu.name}"
  pull_triggers = ["${data.docker_registry_image.ubuntu.sha256_digest}"]
}

resource "docker_container" "ubuntu" {
  image    = "${docker_image.ubuntu.name}"
  must_run = true
  name     = "ubuntu_container"

  ports {
    external = 2222
    internal = 22
  }
}
```
> ./outputs.tf

```hcl
output "container_hostname" {
  description = "The hostname of the container."
  value       = "127.0.0.1"
}
```

> ./test/integration/example/inspec.yml

```yaml
name: example
```

> ./test/integration/example/controls/operating_system.rb

```ruby
# frozen_string_literal: true

control "operating_system" do
  describe "the operating system" do
    subject do
      command("lsb_release -a").stdout
    end

    it "is Ubuntu" do
      is_expected.to match /Ubuntu/
    end
  end
end
```

Running the following command would initialize the working directory for
Terraform, create a Docker container by applying the configuration file,
and verify that the container is running Ubuntu.

> Verifying with Kitchen-Terraform

```sh
$ bundle install
$ bundle exec kitchen test
-----> Starting Kitchen...
...
$$$$$$ Running command `terraform init...`
...
$$$$$$ Running command `terraform apply...`
...
       docker_container.ubuntu: Creation complete after 1s...

       Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
...
       Finished converging <example-ubuntu>...
...
-----> Verifying <example-ubuntu>...
       Verifying host 'localhost' of group 'container'
...
  ✔  operating_system: the operating system is Ubuntu
...
Profile Summary: 1 successful control, 0 control failures, 0 controls skipped
...
```

More information can be found on the
[Kitchen-Terraform Tutorials][kitchen-terraform-tutorials] page.

## Contributing

Kitchen-Terraform thrives on community contributions.

Information about contributing to Kitchen-Terraform can be found in the
[Contributing document][contributing-document].

## Developing

Pull requests to Kitchen-Terraform are always welcome!

Information about developing Kitchen-Terraform can be found in the
[Developing document][developing-document].

## Changelog

Kitchen-Terraform adheres to semantic versioning and documents all
significant changes accordingly.

Information about changes to Kitchen-Terraform can be found in the
[Changelog][changelog].

## Maintainers

Kitchen-Terraform is maintained by New Context.

<img
  alt="New Context logo"
  height="25"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/new_context_logo.png"
  width="25"> [NewContext.com][new-context]

<img
  alt="Twitter logo"
  height="25"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/twitter_logo.png"
  width="25"> [@NewContext][new-context-twitter]

<img
  alt="LinkedIn logo"
  height="23"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/linkedin_logo.png"
  width="25"> [New Context][new-context-linkedin]

<img
  alt="GitHub logo"
  height="25"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/github_logo.png"
  width="25"> [@NewContext][new-context-github]

<img
  alt="Email logo"
  height="16"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/email_logo.png"
  width="25"> kitchen-terraform@newcontext.com

<img
  alt="Email logo"
  height="16"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/email_logo.png"
  width="25"> info@newcontext.com

## License

Kitchen-Terraform is distributed under the [Apache License][license].

<!-- Markdown links and image definitions -->

[build-status-shield]: https://img.shields.io/travis/newcontext-oss/kitchen-terraform.svg?style=plastic
[build-status]: https://travis-ci.com/newcontext-oss/kitchen-terraform
[bundler-getting-started]: https://bundler.io/#getting-started
[bundler-in-depth]: https://bundler.io/gemfile.html
[bundler]: https://bundler.io/index.html#getting-started
[changelog]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/CHANGELOG.md
[contributing-document]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/CONTRIBUTING.md
[developing-document]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/DEVELOPING.md
[docker]: https://www.docker.com/
[docker-community-edition]: https://store.docker.com/editions/community/docker-ce-server-ubuntu
[docker-provider]: https://www.terraform.io/docs/providers/docker/index.html
[gem-downloads-total-shield]: https://img.shields.io/gem/dt/kitchen-terraform.svg?style=plastic
[gem-downloads-version-shield]: https://img.shields.io/gem/dtv/kitchen-terraform.svg?style=plastic
[gem-version-shield]: https://img.shields.io/gem/v/kitchen-terraform.svg?style=plastic
[gemnasium-shield]: https://img.shields.io/gemnasium/newcontext-oss/kitchen-terraform.svg?style=plastic
[gemnasium]: https://beta.gemnasium.com/projects/github.com/newcontext-oss/kitchen-terraform
[gitter-shield]: https://img.shields.io/gitter/room/kitchen-terraform/Lobby.svg?style=plastic
[gitter]: https://gitter.im/kitchen-terraform/Lobby
[inspec]: https://www.inspec.io/
[kitchen-terraform-gem]: https://rubygems.org/gems/kitchen-terraform
[kitchen-terraform-logo]: https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/logo.png
[kitchen-terraform-tutorials]: https://newcontext-oss.github.io/kitchen-terraform/tutorials/
[license]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/LICENSE
[maintainability-shield]: https://img.shields.io/codeclimate/maintainability/newcontext-oss/kitchen-terraform.svg?style=plastic
[maintainability]: https://codeclimate.com/github/newcontext-oss/kitchen-terraform/maintainability
[new-context-github]: https://github.com/newcontext
[new-context-linkedin]: https://www.linkedin.com/company/-new-context-
[new-context-twitter]: https://twitter.com/newcontext
[new-context]: https://newcontext.com/
[rbenv]: https://github.com/rbenv/rbenv
[ruby-branches]: https://www.ruby-lang.org/en/downloads/branches/
[ruby-gem-documentation]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/
[ruby-gems-what-is]: http://guides.rubygems.org/ruby-gems-what-is/index.html
[ruby-installation]: https://www.ruby-lang.org/en/documentation/installation/
[ruby]: https://www.ruby-lang.org/en/
[rubygems-installing-gems]: http://guides.rubygems.org/rubygems-basics/#rubygems-installing-gems
[terraform-cli]: https://www.terraform.io/docs/commands/index.html
[terraform-driver]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Driver/Terraform
[terraform-install]: https://www.terraform.io/intro/getting-started/install.html
[terraform-provisioner]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Provisioner/Terraform
[terraform-verifier]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Verifier/Terraform
[terraform]: https://www.terraform.io/
[test-coverage-shield]: https://img.shields.io/codeclimate/c/newcontext-oss/kitchen-terraform.svg?style=plastic
[test-coverage]: https://codeclimate.com/github/newcontext-oss/kitchen-terraform/test_coverage
[test-kitchen-configuration-file]: https://docs.chef.io/config_yml_kitchen.html
[test-kitchen]: http://kitchen.ci/index.html
[tfenv]: https://github.com/kamatama41/tfenv
