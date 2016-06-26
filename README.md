# kitchen-terraform
*A set of Test Kitchen plugins for testing Terraform configurations*

## Requirements

- [Terraform] **(~> 0.6)**

[Terraform]: https://www.terraform.io/downloads.html

## Plugins

The provided plugins must all be used together in the Test Kitchen configuration.

### Kitchen::Driver::Terraform

The driver is responsible for validating the installed version of Terraform against the supported version and applying a destructive plan to the Terraform state based on the Terraform configuration provided to the provisioner. 

#### Configuration

There are no configuration options for the driver. 

#### Example

```yaml
---
driver:
  name: terraform
...
```

### Kitchen::Provisioner::Terraform

The provisioner is responsible for applying a constructive plan to the Terraform state based on the provided Terraform configuration. 

#### Configuration

##### directory

The pathname of the directory containing the Terraform configuration to be tested.

###### Example 

```yaml
---
provisioner:
  name: terraform
  directory: directory/containing/terraform/configuration
...
```

###### Default 

The default `directory`is the current working directory of Test Kitchen.

##### variable_files

A pathname or a collection of pathnames of Terraform variable files containing variables to be set in the configuration.

###### Examples

```yaml
---
provisioner:
  name: terraform
  variable_files: a/terraform/variable/file
---
provisioner:
  name: terraform
  variable_files:
    - first/terraform/variable/file
    - second/terraform/variable/file
...
```

###### Default 

The default `variable_files` collection is empty. 

##### variables

A Terraform variable or a collection of variables to be set in the configuration. 

###### Examples 

```yaml
---
provisioner:
  name: terraform
  variables: foo=bar
---
provisioner:
  name: terraform
  variables:
    - foo=bar
    - biz=baz
...
```

###### Default 

The default `variables` collection is empty.

### Kitchen::Verifier::Terraform

The verifier is responsible for verifying the server instances in the Terraform state using [Inspec profiles].

[Inspec profiles]: https://github.com/chef/inspec/blob/master/docs/profiles.rst

#### Configuration

The verifier inherits from `[Kitchen::Verifier::Inspec]` so any configuration supported by that class will be supported, save for the values managed under `groups`. 

[Kitchen::Verifier::Inspec]: https://github.com/chef/kitchen-inspec/blob/master/lib/kitchen/verifier/inspec.rb

##### groups 

A collection of group mappingsmappings containing control and connection options for the different server instance groups in the Terraform configuration.

Each group consists of:

- a name to use for logging purposes 

- a mapping ofof Inspec attribute names to Terraform output variable names to define for the suite's Inspec profile 

- a collection of controls to include from the suite's Inspec profile 

- a hostnames output variable name to use for extracting hostnames from the Terraform state; the output value is assumed to be in CSV format 

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
