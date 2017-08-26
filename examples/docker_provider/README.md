# Terraform Docker Provider Example

This is an example of how to utilize kitchen-terraform to test a Docker
container running on localhost configured with the
[Terraform Docker Provider].

## Requirements

A Docker host be listening on the Unix socket located at
`unix://localhost/var/run/docker.sock`.

The Docker container to be tested must be running an SSH daemon in the
foreground to enable the kitchen-terraform verifier to remotely execute
tests.

## Terraform Configuration File

The Terraform configuration exists in (main.tf).

### Terraform Configuration

The configuration is restricted to Terraform versions equal to or
greater than 0.10.2 and less than 0.11.0.

The local backend is configured to demonstrate support for backends.

### Docker Provider

The Docker provider is configured to communicate with a Docker host
listening on a Unix socket on localhost.

### Docker Registry Image Data Source

A [SSH daemon Docker image] from the public registry is configured as a
data source.

### Docker Image

A Docker image is configured on the Docker host using the data source.

### Docker Container

A Docker container based on the Docker image is configured to be running
on the Docker host. The container forwards localhost:2222 to its
internal SSH daemon.

### Outputs

The path of the backend state file and the localhost hostname are
configured as outputs for use by the kitchen-terraform verifier.

## Test Kitchen Configuration File

The Test Kitchen configuration exists in [.kitchen.yml].

### Driver

The kitchen-terraform driver is enabled.

### Provisioner

The kitchen-terraform provisioner is enabled.

### Transport
The Test Kitchen SSH transport is configured to use password
authentication.

### Verifier
The kitchen-terraform verifier is configured with two groups.

The `container` group includes a control for the operating system of the
Docker container. Iterating over the elements of the `hostnames` output,
the verifier will run the control against `localhost` over SSH on port
`2222`.

### Platforms

The platforms provide arbitrary grouping for the test suite matrix.

### Suites

The suite name corresponds to the integration test directory pathname.

## Test Kitchen Execution

```
$ bundle install
$ bundle exec kitchen test
```

[Terraform Docker Provider]: https://www.terraform.io/docs/providers/docker/index.html
[SSH daemon Docker image]: https://hub.docker.com/r/rastasheep/ubuntu-sshd/
