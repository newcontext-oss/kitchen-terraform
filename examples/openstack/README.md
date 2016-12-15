# OpenStack example

This example shows how to use kitchen-terraform with OpenStack Terraform provider.

## Prerequisites

### OpenStack
In order to keep this example short: we assume there are already 2 networks
 created. You have to set their names in a Terraform variables file.

In order to keep this example easy to use without many customizations: we
 import a keypair into OpenStack. The private and public keys are in `dummy_keypair`
 directory and they are used to ssh login into OpenStack vms.

Still some customizations are needed and you should apply them in a Terraform
 variables file. You have to create that file: `my-variables.tfvars` with
 contents similar to:
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

### Other
This was tested with:
 * kitchen-terraform 0.3.0
 * test-kitchen 1.14.2
 * Terraform 0.7.13
 * ruby 2.3.1

## Running tests
The Terraform files create a cluster of OpenStack vms. Each vm is either:
 a master or a worker. You can change the number of master or worker vms anytime.

In this example, by default, tests are run on 1 master vm and all worker vms.
This is set in `.kitchen.yml` by `master_0_public_ip` and `workers_public_ips`. Values of
 `master_0_public_ip` and `workers_public_ips` are taken from `outputs.tf`.
If you want to run tests on all master vms, you need to edit
 `.kitchen.yml` so that it contains `masters_public_ips` instead of `master_0_public_ip`.
Then run
```
bundle exec kitchen converge
bundle exec kitchen verify
```
