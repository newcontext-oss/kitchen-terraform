# kitchen-terraform
*A set of Test Kitchen plugins for testing Terraform configurations*

## Requirements

- [Terraform] **(~> 0.6)**

[Terraform]: https://www.terraform.io/downloads.html

## Plugins

### Kitchen::Driver::Terraform

The driver is responsible for validating the installed version of Terraform against the supported version and applying a destructive plan to the existing state.

#### Configuration

There are no configuration options for the driver. 

#### Example

*.kitchen.yml*

```yaml
driver:
  name: terraform
```

