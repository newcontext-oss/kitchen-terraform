# Examples

This directory contains an example Terraform project that creates
infrastructure on [Amazon Web Services (AWS)] and utilizes
kitchen-terraform for testing the server instances.

[Amazon Web Services (AWS)]: https://aws.amazon.com/index.html

While the complexity of the Terraform code has been kept to a minimum,
it is possible that the configuration of a user's AWS account may still
prevent the successful execution of this example.

## Terraform Configuration

[variables.tf] defines the required inputs for the example module.

[variables.tf]: variables.tf

[example.tf] creates three server instances: two in the
*kitchen_terraform_example_1* group and one in the
*kitchen_terraform_example_2* group.

[example.tf]: example.tf

[outputs.tf] defines two output variables: the hostnames of the
instances in the test suite's only group and an address to use in the
suite's Inspec controls.

[outputs.tf]: outputs.tf

## Test Kitchen Configuration

The [Test Kitchen configuration] includes all of the plugins provided by
kitchen-terraform.

[Test Kitchen configuration]: .kitchen.yml

### Driver

The driver has no configuration options.

### Provisioner

The provisioner is configured to use a [variables file] to provide some
of the variables required by the example module.

[variable file]: test/fixtures/credentials.tfvars

### Transport

The SSH transport is used due to the AMI used in the example module.

### Verifier

The verifier is configured with a single group named `contrived`.

The `contrived` group uses the value of the `different_host_address` output
to define an Inspec control attribute named `other_host_address` and
includes both of the suite's [profile's controls]. The group uses the
value of the `contrived_hostnames` output to obtain the targets to
execute the controls on and provides a static port and username based on
the AMI used in the example module.

[profile's controls]: test/integration/example/controls

### Platforms

The platforms configuration is currently irrelevant but must not be
empty.

### Suites

The suite name corresponds to the [integration test directory pathname]
as usual.

[integration test directory pathname]: test/integration/example

### Missing Configuration

Several required configuration options are missing from the Test Kitchen
configuration; these must be provided in a local Test Kitchen
configuration.

*.kitchen.local.yml*

```yaml
---
transport:
  ssh_key: <pathname/of/private/ssh/key>
suites:
  - name: example
    provisioner:
      variables:
        - access_key=<aws_access_key_id>
        - public_key_pathname=<pathname/of/public/ssh/key>
        - secret_key=<aws_secret_access_key>
...
```

## Executing Tests

Assuming that the [missing configuration] has been provided, testing the
example module is simple:

[missing configuration]: README.md#user-content-missing-configuration

```sh
$ bundle
$ bundle exec kitchen converge
# Wait for the instances to be ready for SSH connections...
$ bundle exec kitchen verify
$ bundle exec kitchen destroy
```
