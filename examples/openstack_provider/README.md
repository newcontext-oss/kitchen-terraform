# OpenStack Provider Example

This is an example of how to utilize kitchen-terraform to test OpenStack
resources configured with the [Terraform OpenStack provider].

## Requirements

Two OpenStack networks that are accessible from localhost.

## Terraform Configuration File

The Terraform configuration exists in (main.tf).

### Variables

Some networking and provider attributes are required.

### Resources

The key pair in the `dummy_keypair` directory is imported in to
OpenStack and used for SSH authentication with VMs.

A cluster of one master VM and two worker VMs is created.

## Test Kitchen Configuration File

The Test Kitchen configuration exists in (.kitchen.yml).

### Driver

The kitchen-terraform driver is configured with a command timeout of
1000 seconds and the path to a Terraform variables file.

### Provisioner

The kitchen-terraform provisioner is enabled.

### Transport

The Test Kitchen SSH transport is configured to use the `dummy_keypair`
and a static username for SSH authentication with the VMs.

### Verifier

The kitchen-terraform verifier is configured with two groups.

The `master` group is configured to run a control against the master VM
by using the `master_address` output for the value of hostnames.

The `workers` group is configured to run a control against all of the
worker VMs by using the `workers_addresses` output for the value of
hostnames.

## Terraform Variables File

The Terraform variables file must be defined at `./my-variables.tfvars`
with variables required by the Terraform configuration.

```hcl
compute_instances_network_name = "<VALUE>"
networking_floatingips_pool    = "<VALUE>"
provider_auth_url              = "<VALUE>"
provider_passowrd              = "<VALUE>"
provider_region                = "<VALUE>"
provider_tenant_name           = "<VALUE>"
provider_user_name             = "<VALUE>"
```

## Test Kitchen Execution

```
bundle install
bundle exec kitchen test
```

[Terraform OpenStack provider]: https://www.terraform.io/docs/providers/openstack/index.html
