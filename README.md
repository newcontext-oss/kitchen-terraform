# kitchen-terraform

kitchen-terraform is a set of [Test Kitchen] plugins for testing
[Terraform configuration].

[Test Kitchen]: http://kitchen.ci/index.html

[Terraform configuration]: https://www.terraform.io/docs/configuration/index.html

## Requirements

- [Ruby] **(~> 2.3)**

- [Bundler] **(~> 1.12)**

- [Terraform] **(~> 0.6)**

[Ruby]: https://www.ruby-lang.org/en/index.html

[Bundler]: https://bundler.io/index.html

[Terraform]: https://www.terraform.io/index.html

## Installation

kitchen-terraform is packaged as a cryptographically signed [Ruby gem]
which means it can be [installed with Bundler].

First, the author's public key must be added as a trusted certificate:

```sh
gem cert --add <(curl --location --silent \
https://raw.githubusercontent.com/newcontext/kitchen-terraform/master/certs/ncs-alane-public_cert.pem)
```

Then, install the bundle and verify all of the gems:

```sh
bundle install --trust-policy HighSecurity
```

[Ruby Gem]: http://guides.rubygems.org/what-is-a-gem/index.html

[installed with Bundler]: https://bundler.io/index.html#getting-started

## Usage

The provided plugins must all be used together in the
[Test Kitchen configuration] in order to successfully test the provided
Terraform configuration.

[Test Kitchen configuration]: https://docs.chef.io/config_yml_kitchen.html

Refer to the [examples directory] for a detailed example project.

[examples directory]: examples/

## Plugins

### Driver

The [driver] is responsible for ensuring compatibility with Terraform and
destroying existing [Terraform state].

[driver]: lib/kitchen/driver/terraform.rb

[Terraform state]: https://www.terraform.io/docs/state/index.html

#### Actions

##### kitchen create

The driver validates the installed version of
Terraform against the version supported by kitchen-terraform.

##### kitchen destroy

The driver applies a destructive [Terraform plan] to the
Terraform state based on the Terraform configuration provided to the
provisioner.

[Terraform plan]: https://www.terraform.io/docs/commands/plan.html

#### Configuration

There are no configuration options for the driver.

##### Example

*.kitchen.yml*

```yaml
---
driver:
  name: terraform
```

### Provisioner

The [provisioner] is responsible for creating Terraform state.

[provisioner]: lib/kitchen/provisioner/terraform.rb

#### Actions

##### kitchen converge

The provisioner applies a constructive Terraform plan to the
Terraform state based on the provided Terraform configuration.

#### Configuration

##### directory

The pathname of the directory containing the Terraform configuration
to be tested; corresponds to the [directory specified] in several
Terraform commands.

[directory specified]: https://www.terraform.io/docs/configuration/load.html

###### Example

*.kitchen.yml*

```yaml
---
provisioner:
  name: terraform
  directory: directory/containing/terraform/configuration
```

###### Default

The default `directory` is the current working directory of Test Kitchen.

##### variable_files

A collection of pathnames of [Terraform variable files] to be evaluated
for the configuration.

[Terraform variable files]: https://www.terraform.io/docs/configuration/variables.html#variable-files

###### Examples

*.kitchen.yml*

```yaml
---
provisioner:
  name: terraform
  variable_files:
    - first/terraform/variable/file
    - second/terraform/variable/file
---
provisioner:
  name: terraform
  variable_files: a/terraform/variable/file
```

###### Default

The default `variable_files` collection is empty.

##### variables

A collection of [Terraform variables] to be set in the configuration;
the syntax matches that of [assigning variables] with command-line
flags.

[Terraform variables]: https://www.terraform.io/docs/configuration/variables.html

[assigning variables]: https://www.terraform.io/intro/getting-started/variables.html#assigning-variables

###### Examples

*.kitchen.yml*

```yaml
---
provisioner:
  name: terraform
  variables:
    - foo=bar
    - biz=baz
---
provisioner:
  name: terraform
  variables: foo=bar
```

###### Default

The default `variables` collection is empty.

### Verifier

The [verifier] is responsible for verifying the behaviour of any server
instances in the Terraform state.

[verifier]: lib/kitchen/verifier/terraform.rb

#### Actions

##### kitchen verify

The verifier verifies the configured server instances in the Terraform
state using [Inspec profiles].

[Inspec profiles]: https://github.com/chef/inspec/blob/master/docs/profiles.rst

#### Configuration

The verifier inherits from [kitchen-inspec] and should support any
configuration defined by that plugin with the exception of the `port` and
`username` configuration which are specified under `groups`.

[kitchen-inspec]: https://github.com/chef/kitchen-inspec/

##### groups

A collection of group mappings containing [Inspec control] and
connection options for the different server instance groups in the
Terraform configuration.

[Inspec control]: https://github.com/chef/inspec/blob/master/docs/dsl_inspec.rst

Each group consists of:

- a name to use for logging purposes

- a mapping of Inspec attribute names to Terraform output variable
  names to define for the suite's Inspec profile

- a collection of controls to include from the suite's Inspec profile

- a hostnames output variable name to use for extracting hostnames from
  the Terraform state; the output value is assumed to be in CSV format

- the port to use when connecting to the group's hosts

- the username to use when connecting to the group's hosts

###### Example

*.kitchen.yml*

```yaml
---
verifier:
  name: terraform
  groups:
    - name: arbitrary
      attributes:
        foo: bar
      controls:
        - biz
      hostnames: hostnames_output
      port: 123
      username: test-user
```

###### Defaults

The default `groups` collection is empty.

For each group:

- the default `attributes` mapping is empty

- the default `controls` collection is empty

- the default `port` is obtained from the transport

- the default `username` is obtained from the transport
