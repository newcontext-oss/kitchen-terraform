# kitchen-terraform
*A set of Test Kitchen plugins for testing Terraform configurations*

## Requirements

- [Terraform] **(~> 0.6)**

[Terraform]: https://www.terraform.io/downloads.html

## Plugins

### Kitchen::Driver::Terraform

The driver is responsible for validating the installed version of Terraform against the supported version and applying a destructive plan to the Terraform state based on the Terraform configuration provided to the provisioner. 

#### Configuration

There are no configuration options for the driver. 

#### Example

```yaml
driver:
  name: terraform
```

### Kitchen::Provisioner::Terraform

The provisioner is responsible for applying a constructive plan to the Terraform state based on the provided Terraform configuration. 

#### Configuration

##### directory

The pathname of the directory containing the Terraform configuration to be tested.

###### Default 

The default `directory`is the current working directory of Test Kitchen.

###### Example 

```yaml
provisioner:
  name: terraform
  directory: directory/containing/terraform/configuration
```

##### variable_files

A pathname or an array of pathnames of Terraform variable files containing variables to be set in the configuration.

###### Default 

The default `variable_files` array is empty. 

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
```

##### variables

A Terraform variable or a list of variables to be set in the configuration. 

###### Default 

The default `variables` list is empty.

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
```
