# kitchen-terraform

kitchen-terraform is a set of [Test Kitchen] plugins for testing
[Terraform configuration].

[Test Kitchen]: http://kitchen.ci/index.html

[Terraform configuration]: https://www.terraform.io/docs/configuration/index.html

## Requirements

- [Bundler] **(~> 1.12)**

- [Terraform] **(~> 0.6)**

[Bundler]: https://bundler.io/index.html

[Terraform]: https://www.terraform.io/index.html

## Plugins

The provided plugins must all be used together in the
[Test Kitchen configuration].

[Test Kitchen configuration]: https://docs.chef.io/config_yml_kitchen.html

### [Kitchen::Driver::Terraform]

[Kitchen::Driver::Terraform]: lib/kitchen/driver/terraform.rb

The driver is responsible for validating the installed version of
Terraform against the supported version and applying a destructive
[Terraform plan] to the [Terraform state] based on the Terraform
configuration provided to the provisioner.

[Terraform plan]: https://www.terraform.io/docs/commands/plan.html

[Terraform state]: https://www.terraform.io/docs/state/index.html

#### Configuration

There are no configuration options for the driver.

#### Example

```yaml
---
driver:
  name: terraform
...
```

### [Kitchen::Provisioner::Terraform]

[Kitchen::Provisioner::Terraform]: lib/kitchen/provisioner/terraform.rb

The provisioner is responsible for applying a constructive plan to the
Terraform state based on the provided Terraform configuration.

#### Configuration

##### directory

The pathname of the directory containing the Terraform configuration
to be tested; corresponds to the [directory specified] in several
Terraform commands.

[directory specified]: https://www.terraform.io/docs/configuration/load.html

###### Example

```yaml
---
provisioner:
  name: terraform
  directory: directory/containing/terraform/configuration
...
```

###### Default

The default `directory` is the current working directory of Test Kitchen.

##### variable_files

A collection of pathnames of [Terraform variable files] to be evaluated
for the configuration.

[Terraform variable files]: https://www.terraform.io/docs/configuration/variables.html#variable-files

###### Examples

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
...
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
...
```

###### Default

The default `variables` collection is empty.

### [Kitchen::Verifier::Terraform]

[Kitchen::Verifier::Terraform]: lib/kitchen/verifier/terraform.rb

The verifier is responsible for verifying the server instances in the
Terraform state using [Inspec profiles].

[Inspec profiles]: https://github.com/chef/inspec/blob/master/docs/profiles.rst

#### Configuration

The verifier inherits from [Kitchen::Verifier::Inspec] so any
configuration supported by that class will be supported, save for the
values managed under `groups`.

[Kitchen::Verifier::Inspec]: https://github.com/chef/kitchen-inspec/blob/master/lib/kitchen/verifier/inspec.rb

##### groups

A collection of group mappingsmappings containing control and connection
options for the different server instance groups in the Terraform
configuration.

Each group consists of:

- a name to use for logging purposes

- a mapping ofof Inspec attribute names to Terraform output variable
names to define for the suite's Inspec profile

- a collection of controls to include from the suite's Inspec profile

- a hostnames output variable name to use for extracting hostnames from
  the Terraform state; the output value is assumed to be in CSV format

- the port to use when connecting to the group's hosts

- the username to use when connecting to the group's hosts

###### Example

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
...
```

###### Defaults

The default `groups` collection is empty.

For each group:

- the default `attributes` mapping is empty

- the default `controls` collection is empty

- the default `port` is obtained from the transport

- the default `username` is obtained from the transport
