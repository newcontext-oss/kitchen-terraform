**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

  - [Getting started with kitchen-terraform](#)
  - [Simple Example - Getting Started](#)
  - [Our Tools](#)
  - [Prerequisites](#)
  - [Setting up our development environment](#)
  - [Setting up Test Kitchen](#)
  - [Writing a test](#)
  - [Complex Example](#)
  - [Terraform Configuration](#)
  - [Test Kitchen Configuration](#)
  - [Driver](#)
  - [Provisioner](#)
  - [Transport](#)
  - [Verifier](#)
  - [Platforms](#)
  - [Suites](#)
  - [Missing Configuration](#)
- [Executing Tests](#)

# Getting started with kitchen-terraform

# Simple Example - Getting Started

  Hello!  This tutorial will walk you through setting up a Terraform config to spin up an AWS EC2 instance using Inspec and
  kitchen-terraform from scratch.

(Note: these instructions are for Unix based systems only)

## Our Tools
  * [Terraform][1]
  * [Test Kitchen][2]
  * [InSpec][3]
  * [kitchen-terraform][4]

## Prerequisites

  Make sure you have the following prerequisites for this tutorial
  * An AWS Account
  * An AWS Access Key ID
  * An AWS Secret Key
  * An AWS Keypair
  * Terraform installed
  * Bundler installed
  * Ruby 2.3.1
  * The default security group on your account must allow ssh access from your ip address

  So let's start building this config from scratch!

## Setting up our development environment

  First, let's create a new directory for our config:

  ```bash
  $ mkdir tf_aws_cluster
  ```

  And cd into that directory:

  ```bash
  $ cd tf_aws_cluster
  ```

  Now, create some skeleton terraform files:

  ```bash
  $ touch main.tf variables.tf output.tf testing.tfvars
  ```

  Add in a `Gemfile`:
  ```bash
  $ vim Gemfile
  ```

  Edit the `Gemfile ` and add in the `kitchen-terraform` gem like so:
  ```ruby
  source 'https://rubygems.org/'
  ruby '2.3.1'

  gem 'test-kitchen'
  gem 'kitchen-terraform'
  ```

  Close and save the file then run `bundler` to install these gems:
  ```bash
  $ bundle install
  ```

## Setting up Test Kitchen

  Now let's set up Test Kitchen.

  Go ahead and open your `.kitchen.yml` file:
  ```bash
  $ vim .kitchen.yml
  ```

  Let's go ahead and add in configuration for for both test kitchen and kitchen-terraform in the `.kitchen.yml` config file.

  Kitchen-terraform provides three plugins for use with test kitchen - a driver, a provisioner, and a verifier. We will go through each of these plugins in this tutorial.

  First the driver - the driver we are using is called terraform

  Edit the `.kitchen.yml`:
  ```yaml
  ---
  driver:
name: terraform
```

Now let's add the provisioner.  The provisioner we will use is also called `terraform`.

```yaml
---
driver:
name: terraform

provisioner:
name: terraform
variable_files:
- testing.tfvars
```

Now, we need to add in a platform.  Although our terraform config will determine what OS we use, we need to include at least one value here.
```yaml
---
driver:
name: terraform

provisioner:
name: terraform
variable_files:
- testing.tfvars

platforms:
- name: ubuntu
```

Next, let's add the transport section. This is what will allow
kitchen-terraform to ssh into your terraform'd instances and run your
inspec tests. You will need to include the path to the private key half
of your AWS keypair - wherever you keep it on your workstation.
```yaml
---
driver:
name: terraform

provisioner:
name: terraform
variable_files:
- testing.tfvars

platforms:
- name: ubuntu

transport:
name: ssh
ssh_key: ~/path/to/your/private/aws/key.pem
```

And now let's add another section, the verifier section.  The verifier
is what will verify whether your test kitchen instances match what is
laid out in your inspec files.
```yaml
---
driver:
name: terraform

provisioner:
name: terraform
variable_files:
- testing.tfvars

platforms:
- name: ubuntu

transport:
name: ssh
ssh_key: ~/path/to/your/private/aws/key.pem

verifier:
name: terraform
format: doc
groups:
- name: default
tests:
- operating_system
hostnames: public_dns
username: ubuntu
```

And let's stop and talk about what we did here - as this is where you
will see some of the uniqueness of kitchen-terraform.

With these lines:

```yaml
verifier:
name: terraform
format: doc
```

We have specified that we are using the terraform verifier.  We are also
using the format type of doc for our tests' output.

And we have also specified a group of tests.

```yaml
groups:
- name: default
tests:
- operating_system
hostnames: public_dns
username: ubuntu
```

Our group's name is `default`, and we expect to find a test file
called `operating_system_spec.rb` within that group.

Additionally, kitchen-terraform also needs to know what hostnames it
needs to ssh into to run our specs.  We have specified `public_dns` -
which is an output value we will need to add to `output.tf` in a bit.

Finally, there is the username - this is the name kitchen terraform will
use to ssh into the hostnames with.  In this tutorial we are using
Ubuntu instances and the default username is `ubuntu`.

And, last, let's add a test suite to `.kitchen.yml`:
```yaml
---
driver:
name: terraform

provisioner:
name: terraform
variable_files:
- testing.tfvars

platforms:
- name: ubuntu

transport:
name: ssh
ssh_key: ~/path/to/your/private/aws/key.pem

verifier:
name: terraform
format: doc
groups:
- name: default
tests:
- operating_system
hostnames: public_dns
username: ubuntu

suites:
- name: default
```

Save and close the file.

## Writing a test

Now, we have some work to do on our workstation.  First, let's set up
an `inspec` directory within our test directories

```bash
$ mkdir -p test/integration/default/controls
```

This will be our default group of tests.  Now we need to provide a yml
file with the name of that group within the group directory.  Go ahead
and create this:
```bash
$ vim test/integration/default/inspec.yml
```

And add this content:
```yaml
---
name: default
```

Save and close the file.

Now, just one more bit of housekeeping.  Our `.kitchen.yml` is expecting
an output of our test kitchen instances' hostnames within the output
variable, `public_dns`. In order to have a hostname within that `public_dns`
variable, we need to create an EC2 instance.

First, open up the main config file:

```bash
$ vim main.tf
```

And add this content:

```
provider "aws" {
  access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name      = "${var.key_name}"
}
```

Save and close the file.  Notice that we used some variable values
there?  We need to add these into our `variables.tf` file.

Go ahead and create it.

```bash
$ vim variables.tf
```

And add in this content:

```
variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}
variable "region" {}
variable "ami" {}
variable "instance_type" {}
```

And, finally, we need to add in some values for these variables.

Open up your `testing.tfvars` file

```bash
$ vim testing.tfvars
```

And add in this content (substitute in the appropriate values for your
    AWS account, region, etc.)

```
access_key = "my_aws_access_key"
secret_key = "my_aws_secret_key"
key_name = "my_aws_key_pair_name"
region = "us-east-1"
ami = "ami-fce3c696"
instance_type = "m3.medium"
```

Save and close the file.

Finally, let's define that output that will be expected by our
`.kitchen.yml`.

Go ahead and open up your `output.tf` file.

```bash
$ vim output.tf
```

And add this content

```
output "public_dns" {
  value = "${aws_instance.example.public_dns}"
}
```

Ok!  Now we're ready to finally create some test kitchen instances!

Go ahead and run:
```bash
$ bundle exec kitchen converge
```

NOTE: If you receive the error "Error launching source instance:
VPCResourceNotSpecified: The specified instance type can only be
used in a VPC", check out [this documentation for help correcting it](http://docs.rightscale.com/faq/EC2_t2.x_Instance_Type_Requirement.html)

And it should converge successfully and you should see output that
includes

```
Outputs:

public_dns = your_aws_instance_public_ip
```

Let's first try running the tests as is - even though we haven't written
any yet.

```bash
$ bundle exec kitchen verify
```

And if it runs successfully, you should see output that includes

```
0 examples, 0 failures
```

Let's add some tests!

Open up the file

```bash
$ vim test/integration/default/controls/operating_system_spec.rb
```

And let's add in a very basic test to make sure we are running on an
Ubuntu system.

```ruby
describe command('lsb_release -a') do
its('stdout') { should match (/Ubuntu/) }
end
```

Now save and close the file and run the test.

```bash
$ bundle exec kitchen verify
```

And hey, it passed!  You should see output that includes

```
Command lsb_release -a
stdout
should match /Ubuntu/
```

It's nice that it passed...but we still need to make sure that it fails
to be certain it tests what we think it tests.  Let's try changing our
Terraform config to spin up an Amazon Linux System, rather than an
Ubuntu system, and make sure that this test fails.

Go ahead and destroy your current test kitchen instances with:

```bash
$ bundle exec kitchen destroy
```

Open up your variables file

```bash
$ vim testing.tfvars
```

And change this content:

```
region = "us-east-1"
instance_type = "m3.medium"
ami = "ami-fce3c696"
```

To this content (we are changing our AMI type to be an Amazon Linux AMI
    within the us-east-1 AWS region.

    ```
    region = "us-east-1"
    instance_type = "m3.medium"
    ami = "ami-6869aa05"
    ```

    Now create your test kitchen instance:
    ```bash
    $ bundle exec kitchen converge
    ```

    Now run the tests:
    ```bash
    $ bundle exec kitchen verify
    ```

    Whoops!  Looks like we got an error this run!

```
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 1 actions failed.
>>>>>>     Verify failed on instance <default-ubuntu>.  Please see
.kitchen/logs/default-ubuntu.log for more details
```

So let's take a look at the `.kitchen/log/default-ubuntu.log`.  Parsing
through the output, we see this:
```
ERROR -- default-ubuntu: Message: Transport error, can't connect to
'ssh' backend: SSH session could not be established
```

This is because of the verifier in our `.kitchen.yml`

```yaml
verifier:
name: terraform
format: doc
groups:
- name: default
tests:
- operating_system
hostnames: public_dns
username: ubuntu
```

Notice that the username we have specified for our test is `ubuntu` -
this is fine for an ubuntu instance, but for an Amazon Linux instance,
     we need to use the `ec2-user` username

     So let's go ahead and change that, the verifier section of your
     `.kitchen.yml` should now look like this:

     ```yaml
     verifier:
name: terraform
format: doc
groups:
- name: default
tests:
- operating_system
hostnames: public_dns
username: ec2-user
```

Now try running the tests again:

```bash
$ bundle exec kitchen verify
```

And now we see a test failure:

```
1) Command lsb_release -a stdout should match /Ubuntu/
Failure/Error: DEFAULT_FAILURE_NOTIFIER =
lambda { |failure, _opts| raise failure }\
         expected "" to match /Ubuntu/
         Diff:
         @@ -1,2 +1,2 @@
         -/Ubuntu/
         +""
         ```

         Alright, that means our test is failing when it is supposed to be
         failing, and passing when it is supposed to pass.

         Open up your `.kitchen.yml` file and change the username back to ubuntu

         ```yaml
         verifier:
name: terraform
format: doc
groups:
- name: default
tests:
- operating_system
hostnames: public_dns
username: ubuntu
```

And open up your `testing.tfvars` file and switch back to an Ubuntu AMI

```
region = "us-east-1"
instance_type = "m3.medium"
ami = "ami-fce3c696"
```

Then destroy your current kitchen instances:

```bash
$ bundle exec kitchen destroy
```

Then converge again:

```bash
$ bundle exec kitchen converge
```

And then run verify one more time, now you should see everything pass:

```bash
$ bundle exec kitchen verify
```

Huzzah!  This includes our "Getting Started" tutorial.

Now, make sure to destroy your test instances

```bash
$ bundle exec kitchen destroy
```

# Complex Example

This directory contains a more complex example Terraform project that creates infrastructure on [Amazon Web Services (AWS)][5] and utilizes kitchen-terraform for testing the server instances.

While the complexity of the Terraform code has been kept to a minimum,
      it is possible that the configuration of a user's AWS account may still
      prevent the successful execution of this example.

## Terraform Configuration

      [variables.tf](variables.tf) defines the required inputs for the example module.

      [example.tf](example.tf) creates three server instances: two in the
      *kitchen_terraform_example_1* group and one in the
      *kitchen_terraform_example_2* group.

      [outputs.tf](outputs.tf) defines two output variables: the hostnames of the
      instances in the test suite's only group and an address to use in the
      suite's Inspec controls.

## AWS Configuration

      Before continuing, review the instructions on configuring the
      [AWS account] with an isolated user for enhanced security.

      In order to execute this example, AWS credentials must be provided
      according to the [credentials provider chain rules].

      [AWS account]: AWS.md

      [credentials provider chain rules]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence

## Test Kitchen Configuration

      The [Test Kitchen configuration](.kitchen.yml) includes all of the plugins provided by
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

The `contrived` group uses the value of the `different_host_address` output
to define an Inspec control attribute named `other_host_address` and
includes all of the suite's [profile's controls]. The group uses the
value of the `contrived_hostnames` output to obtain the targets to
execute the controls on and provides a static port and username based on
the AMI used in the example module.

The `local` group omits the `hostnames` setting, which means that the
specified control will be executed locally.

[profile's controls]: test/integration/example/controls

### Platforms

The platforms configuration is currently irrelevant but must not be
empty.

### Suites

The suite name corresponds to the [integration test directory pathname](test/integration/example)
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

Assuming that the [missing configuration](README.md#user-content-missing-configuration) has been provided, testing the
example module is simple:

```bash
$ bundle install
$ bundle exec kitchen test --destroy always
```

[1]: https://www.terraform.io/
[2]: https://github.com/test-kitchen/test-kitchen
[3]: https://github.com/chef/inspec
[4]: https://github.com/newcontext/kitchen-terraform
[5]: https://aws.amazon.com/index.html
