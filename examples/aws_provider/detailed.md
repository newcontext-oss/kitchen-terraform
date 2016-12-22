# Detailed

This directory contains a complex example Terraform project that
creates infrastructure on AWS and utilizes kitchen-terraform for testing
the server instances.

While the complexity of the Terraform code has been kept to a minimum,
it is possible that the configuration of a user's AWS account may still
prevent the successful execution of this example.

## Terraform Configuration

[variables.tf] defines the required inputs for the example module.

[example.tf] creates three server instances: two in the
*kitchen_terraform_example_1* group and one in the
*kitchen_terraform_example_2* group.

[outputs.tf] defines two output variables: the hostnames of the
instances in the test suite's only group and an address to use in the
suite's Inspec controls.

## AWS Configuration

Before continuing, review the instructions on configuring the
[AWS account] with an isolated user for enhanced security.

In order to execute this example, AWS credentials must be provided
according to the [credentials provider chain rules].

## Test Kitchen Configuration

The [Test Kitchen configuration] includes all of the plugins provided by
kitchen-terraform.

### Driver

The driver has no configuration options.

### Provisioner

The provisioner is configured to use 4 concurrent operations to apply a
test fixture module based on the installed version of Terraform.

### Transport

The SSH transport is used due to the AMI used in the example module.

### Verifier

The verifier is configured with two groups, `contrived` and `local`.

The `contrived` group uses the value of the `security_group` output
to define an Inspec control attribute named `overridden_security_group`
and includes most of the suite's [profile's controls]. The group uses
the value of the `contrived_hostnames` output to obtain the targets to
execute the controls on and provides a static port and username based on
the AMI used in the example module.

The `local` group omits the `hostnames` setting, which means that its
specified control will be executed locally rather than on remotely
on a server in the Terraform state.

### Platforms

The platforms configuration is currently irrelevant but must not be
empty.

### Suites

The suite name corresponds to the [integration test directory pathname]
as usual.

### Missing Configuration

A couple of required configuration options are missing from the Test
Kitchen configuration; these must be provided in a local Test Kitchen
configuration.

*.kitchen.local.yml*

```yaml
---
provisioner:
  variables:
    public_key_pathname: <pathname/of/public/ssh/key>
transport:
  ssh_key: <pathname/of/private/ssh/key>
```

## Executing Tests

__WARNING__ Creating AWS resources could cost money and be charged to
the AWS Account's bill; neither kitchen-terraform nor its maintainers
are responsible for any incurred costs.

Assuming that the [missing configuration] has been provided, testing the
example module is simple:

```bash
$ bundle install
$ bundle exec kitchen test --destroy always
```

[AWS account]: AWS.md
[Test Kitchen configuration]: .kitchen.yml
[credentials provider chain rules]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence
[example.tf]: example.tf
[integration test directory pathname]: test/integration/example
[missing configuration]: README.md#user-content-missing-configuration
[outputs.tf]: outputs.tf
[profile's controls]: test/integration/example/controls
[variables.tf]: variables.tf
