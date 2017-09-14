# Terraform AWS Provider Detailed Example

This is a detailed example of how to utilize kitchen-terraform to test
AWS resources configured with the [Terraform AWS Provider].

## Requirements

AWS credentials must be provided according to the
[credentials provider chain rules]. These credentials must be authorized
to manage all of the resources in the [Terraform module].

The use of an isolated user as described in the supplemental
[AWS Account Configuration] article is recommended.

## Terraform Configuration Files

The Terraform configuration exists in (module.tf) and
(test/fixtures/us_east_1/main.tf). The module contains the AWS
configuration and the us-east-1 test fixture configuration depends on
the module.

### AWS Configuration Module

#### Variables

The module requires an instances AMI, a key pair public key, a provider
region, and a subnet availability zone to be provided as inputs.

#### AWS Provider

The module configures the AWS Provider to manage resources in a variable
region.

#### Resources

The module configures a virtual private cloud with three instances and
adequate network egress and ingress to allow internal communication as
well communication with localhost.

#### Outputs

The module exports various resource attributes to be used in integration 
testing with kitchen-terraform.

### us-east-1 Test Fixture Configuration

#### Terraform Configuration

The configuration is restricted to Terraform versions equal to or
greater than 0.10.2 and less than 0.11.0.

#### Variable

The configuration requires a key pair public key to be provided as
an input.

#### Module

The configuration includes the module and provides values specific to
the us-east-1 region for the variable inputs.

#### Outputs

The configuration forwards the outputs of the module.

## AWS Configuration

## Test Kitchen Configuration File

The Test Kitchen configuration exists in (.kitchen.yml).

### Driver

The kitchen-terraform driver is configured to use the us-east-1 test
fixture configuration and to use 4 concurrent operations in its actions.

### Provisioner

The kitchen-terraform provisioner is enabled.

### Transport

The Test Kitchen SSH transport is enabled.

### Verifier

The kitchen-terraform verifier is configured with two groups,
`remote` and `local`.

The `remote` group uses the value of the `security_group` output
to define an Inspec control attribute named `overridden_security_group`
and includes some of the controls of the profile of the suite. The
group uses the value of the `test_target_public_dns` output to obtain
the hostnames to execute the controls on and provides a static port and
username based on the AMI used in the example module.

The `local` group omits the `hostnames` setting, which means that its
specified controls will be executed locally rather than remotely on a
server in the Terraform state.

### Platforms

The platforms provide arbitrary grouping for the test suite matrix.

### Suites

The suite name corresponds to the [directory of the Inspec profile].

### Missing Configuration

Public and private key configuration attributes must be provided
in a local Test Kitchen configuration. This demonstrates how
[embedded Ruby] can be used in Test Kitchen configuration.

*.kitchen.local.yml*

```yaml
---
driver:
  variables:
    key_pair_public_key: "<%= ::File.read '/path/to/public/key' %>"
transport:
  ssh_key: "/path/to/private/key"
```

## Test Kitchen Execution

```bash
$ bundle install
$ bundle exec kitchen test
```

[AWS Account Configuration]: AWS.md
[Terraform AWS Provider]: https://www.terraform.io/docs/providers/aws/index.html
[Terraform module]: module.tf
[credentials provider chain rules]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence
[directory of the Inspec profile]: test/integration/example/
[embedded Ruby]: http://www.stuartellis.name/articles/erb/
[missing configuration]: README.md#user-content-missing-configuration
[outputs.tf]: outputs.tf
[variables.tf]: variables.tf
