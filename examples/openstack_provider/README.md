# OpenStack example

This example shows how to use kitchen-terraform with OpenStack Terraform provider.

## Prerequisites

### OpenStack
In order to keep this example short: we assume there are already 2 networks
 created. You have to set their names. The network set by the variable:
 `openstack_floatingip_pool` will be used to obtain the floating IP from,
 for each VM. You have to be able to access that network from your workstation.

In order to keep this example easy to use without many customizations: we
 import a keypair into OpenStack. The private and public keys are in `dummy_keypair`
 directory and they are used to ssh login into OpenStack VMs.

Still some customizations are needed and you can apply them:
  * either in a Terraform variables file
  * or in `.kitchen.yml` file.

If you choose a Terraform variables file, you have to create that file:
 `my-variables.tfvars` with contents similar to:
```
openstack_image  = "ubuntu-16.04-modified"

openstack_tenant_name = "TODO"
openstack_region = "TODO"
openstack_auth_url = "TODO"
openstack_user_name = "TODO"
openstack_password = "TODO"

openstack_vm_network = "TODO"
openstack_floatingip_pool = "TODO"

masters_count = 1
workers_count = 0
```

Otherwise, you can set the variables in `.kitchen.yml`:
```yaml
provisioner:
  name: terraform
  variables:
    openstack_image: ubuntu-16.04-modified
    # ...
```

### Dependencies
This was tested with:
 * kitchen-terraform 0.4.0
 * Test Kitchen 1.14.2
 * Terraform 0.7.13
 * Ruby 2.3.1

## Running tests
The Terraform files create a cluster of OpenStack VMs. Each VM is either:
 a master or a worker. You can change the number of master or worker VMs anytime.

In this example, by default, tests are run on 1 master VM and all worker VMs.
This is set in `.kitchen.yml` by `master_0_public_ip` and `workers_public_ips`. Values of
 `master_0_public_ip` and `workers_public_ips` are taken from `outputs.tf`.
