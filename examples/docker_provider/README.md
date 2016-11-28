# Example running kitchen-terraform with the terraform docker provider

This example will walk you through how to setup your environment to utilize kitchen-terraform to manage and test a local docker container.

## Terraform Configuration

[main.tf] defines the docker provider and associated resources.
[main.tf]: main.tf

[output.tf] defines the output variables available for the Terraform provisioner.
[output.tf]: output.tf

[variables.tf] defines the input variables available for the Terraform provisioner.
[variables.tf]: variables.tf

## Test Kitchen Configuration
`.kitchen.yml` contains the Test Kitchen configuration to enable the testing of the Terraform project.

### Driver
The driver is defined as terraform and does not have any additional configurations.

### Provisioner
The provisioner defines specific variables for Docker to include the host, container, and image used.

### Platforms
This section is irrelevant, but must be populated.

### Transport
The transport defines the mechanism for interacting with the Docker container.

SSH with password authentication is the mechanism defined here. The Docker container that will be used for this example runs the ssh daemon in the foreground in order to allow the verifier to execute tests on the running container.

### Verifier
The verifier defines a single `default` group that includes a single test for the `operating_system` on the `localhost` using port number `2222`. This port is mapped to the docker container's ssh port `22`.

### Suites
The suite name corresponds to the integration test directory pathname.

# Executing Tests
There are some requirements in order to successfully run kitchen-terraform with Docker. Docker must be installed on the system runninb kitchen-terraform.

Additionally, a container must be available that allows ssh to the container. For example, the dockerfile used for this tutorial includes the following line:

```
CMD ["/usr/sbin/ssh", "-D"]
```

Please see the references for creating a dockerfile that will provide the proper container configuration.

## Test Kitchen Execution

```
$ bundle install
$ bundle exec kitchen test
```

## References
* [Terraform Docker Provider](https://www.terraform.io/docs/providers/docker/index.html)
* [Dockerizing an SSH daemon service](https://docs.docker.com/engine/examples/running_ssh_service/)
