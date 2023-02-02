# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0)
and this project adheres to
[Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][unreleased]

### Added

- Support for Inspec < 6.0
- Support for `kitchen doctor` command: initially validates driver.client and verifier.systems

### Changed

- Dropped support for Inspec < 4.25.1

## [6.1.0] - 2022-01-22

### Added

- Support for Terraform >= 1.1.0, < 2.0.0.

## [6.0.0] - 2021-07-07

### Added

- Support for Ruby 3.0.
- Support for Kitchen 3.0.

### Changed

- Dropped support for Ruby 2.4, 2.5.
- Dropped Terraform 0.11 and 0.12 from the test matrix.

## [5.8.0] - 2021-05-18

### Added

- Support for Terraform 0.15.

## [5.7.2] - 2021-03-08

### Fixed

- `TF_WARN_OUTPUT_ERRORS` is only set during when running `terraform destroy`
  during `kitchen destroy`. It appears that this change was erroneously declared
  as functional in 4.3.0. :grimacing:

## [5.7.1] - 2021-02-25

### Fixed

- Order of operations for loading InSpec plugins

## [5.7.0] - 2021-02-23

### Added

- Automatic loading of InSpec plugins

### Fixed

- Excluded versions of InSpec which broke support for Kitchen

## [5.6.0] - 2020-12-08

### Added

- Support for Terraform v0.14

## [5.5.0] - 2020-08-25

### Added

- Support for Terraform v0.13.

### Security

- Updated all gem versions to remediate ActiveSupport vulnerability, a
  dependency of the train gem.

## [5.4.0] - 2020-05-31

### Added

- Support for Ruby 2.7.

### Changed

- Gem deployment to RubyGems now takes place with GitHub Actions. Unit and
  Integration tests remain in Travis CI and Appveyor.

## [5.3.0] - 2020-03-08

### Added

- Verifier systems have a `bastion_host_output` attribute which allows a bastion
  host to be obtained from a Terraform output rather than statically defined
  with the `bastion_host` attribute.

### Fixed

- All plugin log messages use consistent levels.
- The output of the `terraform output` command has been reverted to log at the
  debug level rather than the warn level.

## [5.2.0] - 2020-02-27

The "trapped in Atlanta" edition!

### Changed

- Log messages have been adjusted to provide better context and actionable
  information where approriate.

- The dependency on mixlib-shellout has been updated to support installation
  using ChefDK versions 3.9 and newer.

## [5.1.1] - 2019-08-28

### Fixed

- RbNaCl was removed from the gem dependencies to solve for an unexpected
  compatibility issue with InSpec's GCP transport [#351]. Installation
  instructions were linked in the README for configurations which may require
  this gem.

## [5.1.0] - 2019-07-06

### Changed

- InSpec 3 is supported again. It must be explicitly pinned in the `Gemfile`,
  like `gem "inspec", "~> 3.0"`.

### Fixed

- Default values for unsupported configuration attributes inherited from the
  base Kitchen plugins were removed.

## [5.0.0] - 2019-06-06

### Changed

- The supported version of InSpec is 4. This version changes the priority of
  profile attributes configurations:
  1. `systems.x.attrs_outputs`
  1. the default association of attributes to Terraform outputs
  1. `systems.x.attrs`

## [4.9.0] - 2019-05-27

### Added

- Support for Terraform v0.12.

## [4.8.1] - 2019-05-11

### Fixed

- Added a reference to the `client` attribute in the driver documentation.
- Corrected the attribute name in the `verify_version` example.

## [4.8.0] - 2019-04-14

### Added

- The verifier exposes input variables configured through the `variables`
  attribute as InSpec profile attributes prefixed with `input_`; refer to the
  updated [Terraform Verifier documentation][terraform-verifier] for more
  details.

### Changed

- The verifier exposes output variables as InSpec profile attributes prefixed
  with `output_`, though the unprefixed variety of attributes are still
  available for backward compatibility; refer to the updated [Terraform Verifier
  documentation][terraform-verifier] for more details.

## [4.7.0] - 2019-04-13

### Added

- The verifier systems gained a `profile_locations` attribute which enables
  overriding the default InSpec profile location of
  `test/integration/<KITCHEN SUITE NAME>`; refer to the updated [Terraform
  Verifier documentation][terraform-verifier] for more details.

### Changed

- Errors are logged when they are queued while `fail_fast` is disabled.

## [4.6.0] - 2019-04-11

### Added

- The verifier gained a `fail_fast` attribute which toggles fail fast behaviour
  when verifying systems; refer to the updated [Terraform Verifier
  documentation][terraform-verifier] for more details.

## [4.5.0] - 2019-04-10

### Changed

- The output of `terraform output` is logged at the debug level to prevent
  sensitive output values from being printed by default. This output can be
  viewed by enabling the debug log level. For example:
  `kitchen converge INSTANCE --log-level=debug`

## [4.4.0] - 2019-04-06

### Added

- The driver gained a `client` configuration attribute which contains the
  pathname to the Terraform client; refer to the [Terraform Driver
  documentation][terraform-driver] for more details.

### Fixed

- The verifier lost legacy code which was implicity coupled to the SSH transport
  and integrated with InSpec in undocumented ways.

## [4.3.0] - 2019-01-20

### Changed

- `TF_WARN_OUTPUT_ERRORS` is no longer automatically set when running
  `terraform apply` during `kitchen converge`. This change should allow output
  errors to be more quickly exposed to the user.

## [4.2.1] - 2019-01-19

### Changed

- `terraform validate` is now called without `-check-variables=true`. This flag
  already defaults to `true` and will be obsolete for Terraform v0.12.

## [4.2.0] - 2018-12-29

### Added

- The driver gained a `:verify_version` configuration attribute which toggles
  verification of support for the available Terraform version. This feature
  allows unsupported versions of Terraform to be used.

- The gem supports Ruby v2.6.

## [4.1.1] - 2018-12-13

### Fixed

- The Terraform workspace is selected before outputs are retrieved.

## [4.1.0] - 2018-12-09

### Changed

- The bundled version of InSpec is now ~> 3.0. Despite the major version change,
  it is intended to be backward compatible.

## [4.0.6] - 2018-12-02

### Fixed

- `terraform output` is moved from `kitchen converge` to `kitchen verify` to
  ensure Terraform state outputs are up to date for use as InSpec attributes
  regardless of the result of `kitchen converge`.

## [4.0.5] - 2018-12-01

### Fixed

- The escaping of Terraform command-line arguments... Again! Arguments for
  `-backend-config` and `-var` are surrounded by double quotes but are not
  escaped. This compromise is intended to ensure proper handling of arguments
  containing HashiCorp Language (HCL) on Linux, MacOS, and Windows. The
  corresponding values for the Kitchen configuration attributes
  `driver.backend_configurations` and `driver.variables` must be properly
  escaped depending on the execution environment. The
  [Kitchen configuration file](kitchen.yml) used for integration testing of
  Kitchen-Terraform contains examples of escaped HCL values.

## [4.0.4] - 2018-11-21

### Fixed

- The escaping of Terraform command-line arguments

## [4.0.3] - 2018-10-03

### Changed

- The version of InSpec was relaxed to include all versions between 2.2 and 3

## [4.0.2] - 2018-09-26

### Changed

- The version of InSpec was relaxed to include 2.2.70 to enable compatability
  with ChefDK 3.2.30

## [4.0.1] - 2018-09-15

### Fixed

- The version of InSpec was pinned to 2.2.78 as 2.2.101 introduced a breaking
  change to the InSpec profile attributes system

## [4.0.0] - 2018-08-13

"An open-source software release is never late. Nor is it early. It arrives
precisely when the maintainers get around to finishing it." - Gandalf the
Free-As-In-Beer

### Added

- The verifier configuration gained a `:systems` attribute which replaced the
  `:groups` attribute; refer to the updated [Terraform Verifier
  documentation][terraform-verifier] for more details

- The Terraform shell out environment now enables `TF_WARN_OUTPUT_ERRORS` to
  work around [Terraform issue #17655][terraform-issue-17655]

### Changed

- Support for Terraform < 0.11.4 was broken

- Support for InSpec < 2.2.34 was broken

- Support for InSpec >= 2.2.34, < 3 was introduced

- Support for Kitchen < 1.20.0 was broken

- Support for Kitchen ~> 1.23 was introduced

- Support for Ruby 2.2 was broken

- Support for concurrency with the following commands was broken: `create`,
  `converge`, `setup`, and `destroy`

- The deprecated `terraform destroy -force` flag was replaced with the supported
  `terraform destroy -auto-approve` flag

- The working directory of the Terraform shell out environment was changed to
  the value of the `:root_module_directory` attribute of the driver
  configuration

- Support for the `:groups` attribute of the verifier configuration was broken;
  `:systems` replaces `:groups`

- InSpec was reconfigured to use the Kitchen logger for all logging

- InSpec was reconfigured to exclusively return 0 and 1 as exit codes

## [3.3.1] - 2018-04-29

### Changed

- Deprecating support for Ruby 2.2; this version reaches end of life on March
  31, 2018

- Deprecating support for concurrency with the following commands: `create`,
  `converge`, `setup`, and `destroy`; these commands invoke Terraform in a
  manner which is not safe for concurrency

### Fixed

- Escaping the following configuration attributes for safe usage in the shell
  out commands:

  - backend_configurations
  - plugin_directory
  - root_module_directory
  - variable_files
  - variables

- Loading of Kitchen constants to enable the use of Kitchen Rake tasks

## [3.3.0] - 2018-03-22

### Added

- The `lock` configuration attribute of the driver toggles locking of the
  Terraform state file

## [3.2.0] - 2018-03-21

### Added

- Support for Ruby 2.5

## [3.1.0] - 2018-01-07

### Added

- Caveat describing how to use a bastion host with the verifier groups

- Support for InSpec to include > 1.44.8, < 2.0.0

- Support for Test Kitchen to include > 1.16.0, < 2.0.0

### Changed

- Format of changelog to adhere to Keep a Changelog 1.0.0

- Internal success and failure to be modeled without monads

- All driver and provisioner actions to attempt to select or create a Terraform
  workspace

- Format and wording of the verifier `groups` attribute documentation

### Fixed

- Documented supported Terraform version for ClientVersionVerifier
- Failure during `kitchen converge` when no Terraform outputs are defined

- Failure on Windows due to use of single quoted arguments for `-backend-config`
  and `-var`

## [3.0.0] - 2017-11-28

### Added

- Support for Terraform versions >= 0.10.2, < 0.12.0

### Changed

- Update `kitchen create` and `kitchen converge` to initialize and apply,
  respectively

- Driver and provisioner commands use Terraform workspaces

- Execute Terraform commands in an environment including the TF_IN_AUTOMATION
  variable

- Change the lock_timeout configuration attribute of the driver to an integer
  representing seconds

- Remove the state configuration attribute from the driver

- Remove the verify_plugins configuration attribute from the driver

- Rename the directory configuration attribute of the driver to
  root_module_directory

- Lock InSpec to 1.44.8 to maintain support for Ruby 2.2

- Moved examples and tutorials to a
  [GitHub site](https://newcontext-oss.github.io/kitchen-terraform/)

### Fixed

- Issues resolving relative paths in Terraform configuration files

- Links to broken documentation on RubyDoc

## [2.1.0] - 2017-10-11

### Added

- Verifier `:groups` have an optional `:ssh_key` attribute that overrides the
  Test Kitchen SSH Transport `:ssh_key`

## [2.0.0] - 2017-09-13

### Added

- Added a description to the gem specification

- Added support for Terraform version ~> 0.10.2 and the init command

- Added configuration attributes to the driver

  - backend_configurations

  - lock_timeout

  - plugin_directory

  - verify_plugins

- Added the color configuration attribute to the verifier

### Changed

- Dropped support for Terraform versions < 0.10.2

- The driver's variables configuration attribute must be a hash of symbols and
  strings

- Removed configuration attributes from the driver

  - cli

  - plan

### Fixed

- Moved the project version constant to the gem namespace

- Corrected obsolete information in the aws_provider example

## [1.0.2] - 2017-07-16

### Added

- The Bundler Gemfile.lock is committed to enable Code Climate's bundler-audit
  engine and to simplify testing and releasing this gem with Travis CI

- RSpec produces backtraces for failures in Travis CI

### Changed

- The integration tests use Terraform version 0.9.11 instead of version 0.9.10

- The integration tests display the Terraform versions

### Fixed

- The Getting Started guide uses kitchen-terraform 1.0 configuration attributes
  (thanks [@davidbegin])

- The Developing guide uses the new GitHub organization

- The Developing guide drops reference to gem trust policies

## [1.0.1] - 2017-07-05

### Added

- David Begin joined the gem specification authors

### Fixed

- Corrected release date for 1.0.0 in the Change Log

- Added missing diff link for 1.0.0 in the Change Log

- Corrected broken GitHub links in the Read Me (thanks [@davidbegin])

- Add missing thanks in 1.0.0

## [1.0.0] - 2017-07-01

### Added

- Support for output variables with spaces (thanks [@jbussdieker])

### Changed

- Dropped support for Terraform version 0.6

- Dropped support for Ruby 2.1

- Improved project documentation

- Moved all provisioner configuration attributes to the driver

- Dropped support for specifying the configuration attribute `variables` in the
  literal `name=value` notation

- Dropped support for the value of the output variable specified by the
  configuration attribute `hostnames` being in CSV format

- Renamed the configuration attribute `apply_timeout` to `command_timeout`

- Default the configuration attribute `cli` to `"terraform"`

- Default the configuration attribute `color` to be based on the association of
  the Test Kitchen process with a terminal emulator

- Improved the engine for validating configuration attribute values

### Fixed

- Added missing URL to 0.7.0 changes

## [0.7.0] - 2017-04-23

### Added

- Support for Terraform v0.9

## [0.6.1] - 2017-02-23

### Fixed

- `terraform plan` during `kitchen converge` was not reading the state file so
  subsequent converges would create duplicate state (thanks [@johnrengelman])

## [0.6.0] - 2017-02-22

### Added

- Driver configuration option to specify the pathname of the Terraform
  command-line interface

- "terraform_state" InSpec attribute containing the pathname of the state file

### Changed

- Restructured code for better distribution of responsibilities

- Intermediate workflow Terraform commands will be logged at the debug level

### Fixed

- Broken reference to the Getting Started guide (thanks [@nellshamrell])

- Output names for Terraform 0.6 are correctly parsed

- Incomplete InSpec control definition in the Getting Started guide ( thanks
  [@burythehammer])

- Missing descriptions of the plan and state provisioner configuration options

## [0.5.1] - 2017-02-17

### Fixed

- Support for Terraform configurations that do not define any outputs (thanks
  [@johnrengelman])

## [0.5.0] - 2017-01-09

### Added

- Support for Terraform v0.8

- Support for Ruby 2.4

### Fixed

- Docker provider example's group controls configuration

## [0.4.0] - 2016-12-24

### Added

- A shiny, new logo (thanks [@ksexton])

- A shiny, new [Travis CI build plan][travis ci build plan] (thanks
  [@justindossey])

- Support for Ruby 2.1 and 2.2 (thanks [@mrmarbury] and [@m00gs])

- [Code Climate coverage][code climate coverage]

- Group attributes default to a mapping of all Terraform output variables to
  equivalently named InSpec attributes (thanks [@shinka81])

- A Docker provider example (thanks [@errygg])

- An OpenStack provider example (thanks [@xmik])

- Groups with no hostnames will have their controls executed locally; in theory,
  this enables testing of any provider API

- Provisioner configuration for the `terraform apply -parallelism` option
  (thanks [@s3lehtin])

- Clay Thomas, Ewa Czechowska, Erik R. Rygg, Kyle Sexton, and Walter Dolce join
  the gem specification authors

### Changed

- Removed the pin on the RubyGems version from the gem specification (thanks
  [@jbussdieker])

### Fixed

- Use the current version in the Gemfile example (thanks [@walterdolce])

## [0.3.0] - 2016-10-04

### Added

- Support for Terraform v0.7 (thanks [@esword], [@maniacal], and [@nictrix])

- Getting started guide under `examples/getting_started` (thanks
  [@nellshamrell])

- Kevin Dickerson, Nell Shamrell-Harrington, and Michael Glenney join the gem
  specification authors

### Changed

- Example project moved under `examples/detailed` (thanks [@nellshamrell])

- Deprecate support for Terraform v0.6

### Fixed

- Release date of kitchen-terraform v0.2.0

- Remove references to verifying the gem; it's problematic even with low
  security (thanks [@kevindickerson])

## [0.2.0] - 2016-09-12

### Added

- Live log stream of output from Terraform commands

- Coercion and validation of configuration values

- Configuration option for timeout of Terraform apply command

- Configuration option for colored output of Terraform plan and apply commands
  (thanks [@nictrix])

- Configuration of variable assignments using a map

- Getting started guide (thanks [@nellshamrell])

### Changed

- CHANGELOG format is based on [Keep a CHANGELOG] \(thanks [@amaltson]\)

- Gem specification email address (thanks [@mrheath])

- Example project automatically waits for remote SSH to be available

- Improve error handling and messages (thanks [@cullenmcdermott])

- Deprecate configuration of variable assignments using a list or string

### Fixed

- Inspec is pinned at the minor feature level to reduce bug risk

## [0.1.2] - 2016-08-04

### Added

- Link to referenced users' profiles in the Change Log

- Display RuboCop Cop names in Guard output

- Contributing and developing guides (thanks [@nictrix])

- Example instructions suggest IAM user creation for enhanced security ( thanks
  [@nictrix])

### Changed

- Example configuration is compatible with more AWS accounts (thanks [@nictrix])

### Fixed

- Remove enforcement of RubyGems trust policy (thanks [@fivetwentysix])

- Only suggest the LowSecurity RubyGems trust policy; in a clean Bundler
  environment, this is the highest policy that can be successfully applied

- Only enforce code coverage requirements when Guard runs all specs

## [0.1.1] - 2016-07-26

### Added

### Changed

- Replace `0 == fixnum_object` with `fixnum_object.zero?`

- Include LICENSE and README in the gem

- Remove specs from the gem

- Add Nick Willever to the gem specification authors

### Fixed

- Lower the development bundle trust policy to MediumSecurity due to
  rubocop-0.42.0 not being signed :crying_cat_face:

- Fix the line length of the gem specification signing key configuration

- Correct the reference to `bundle install --trust-profile` with
  `bundle install --trust-policy` in the README (thanks [@nellshamrell] and
  [@nictrix])

- Clarify the gem installation instructions in the README (thanks [@nictrix])

## 0.1.0 - 2016-07-22

### Added

- Initial release

[unreleased]:
  https://github.com/newcontext/kitchen-terraform/compare/v6.1.0...HEAD
[6.1.0]: https://github.com/newcontext/kitchen-terraform/compare/v6.0.0...v6.1.0
[6.0.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.8.0...v6.0.0
[5.8.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.7.2...v5.8.0
[5.7.2]: https://github.com/newcontext/kitchen-terraform/compare/v5.7.1...v5.7.2
[5.7.1]: https://github.com/newcontext/kitchen-terraform/compare/v5.7.0...v5.7.1
[5.7.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.6.0...v5.7.0
[5.6.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.5.0...v5.6.0
[5.5.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.4.0...v5.5.0
[5.4.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.3.0...v5.4.0
[5.3.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.2.0...v5.3.0
[5.2.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.1.1...v5.2.0
[5.1.1]: https://github.com/newcontext/kitchen-terraform/compare/v5.1.0...v5.1.1
[5.1.0]: https://github.com/newcontext/kitchen-terraform/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.9.0...v5.0.0
[4.9.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.8.1...v4.9.0
[4.8.1]: https://github.com/newcontext/kitchen-terraform/compare/v4.8.0...v4.8.1
[4.8.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.7.0...v4.8.0
[4.7.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.6.0...v4.7.0
[4.6.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.5.0...v4.6.0
[4.5.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.4.0...v4.5.0
[4.4.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.3.0...v4.4.0
[4.3.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.2.1...v4.3.0
[4.2.1]: https://github.com/newcontext/kitchen-terraform/compare/v4.2.0...v4.2.1
[4.2.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.1.1...v4.2.0
[4.1.1]: https://github.com/newcontext/kitchen-terraform/compare/v4.1.0...v4.1.1
[4.1.0]: https://github.com/newcontext/kitchen-terraform/compare/v4.0.6...v4.1.0
[4.0.6]: https://github.com/newcontext/kitchen-terraform/compare/v4.0.5...v4.0.6
[4.0.5]: https://github.com/newcontext/kitchen-terraform/compare/v4.0.4...v4.0.5
[4.0.4]: https://github.com/newcontext/kitchen-terraform/compare/v4.0.3...v4.0.4
[4.0.3]: https://github.com/newcontext/kitchen-terraform/compare/v4.0.2...v4.0.3
[4.0.2]: https://github.com/newcontext/kitchen-terraform/compare/v4.0.1...v4.0.2
[4.0.1]: https://github.com/newcontext/kitchen-terraform/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/newcontext/kitchen-terraform/compare/v3.3.1...v4.0.0
[3.3.1]: https://github.com/newcontext/kitchen-terraform/compare/v3.3.0...v3.3.1
[3.3.0]: https://github.com/newcontext/kitchen-terraform/compare/v3.2.0...v3.3.0
[3.2.0]: https://github.com/newcontext/kitchen-terraform/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/newcontext/kitchen-terraform/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/newcontext/kitchen-terraform/compare/v2.1.0...v3.0.0
[2.1.0]: https://github.com/newcontext/kitchen-terraform/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/newcontext/kitchen-terraform/compare/v1.0.2...v2.0.0
[1.0.2]: https://github.com/newcontext/kitchen-terraform/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/newcontext/kitchen-terraform/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.7.0...v1.0.0
[0.7.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/newcontext/kitchen-terraform/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/newcontext/kitchen-terraform/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/newcontext/kitchen-terraform/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/newcontext/kitchen-terraform/compare/v0.1.0...v0.1.1
[@amaltson]: https://github.com/amaltson
[@burythehammer]: https://github.com/burythehammer
[@cullenmcdermott]: https://github.com/cullenmcdermott
[@davidbegin]: https://github.com/davidbegin
[@errygg]: https://github.com/errygg
[@esword]: https://github.com/esword
[@fivetwentysix]: https://github.com/fivetwentysix
[@jbussdieker]: https://github.com/jbussdieker
[@johnrengelman]: https://github.com/johnrengelman
[@justindossey]: https://github.com/justindossey
[@kevindickerson]: https://github.com/kevindickerson
[@ksexton]: https://github.com/ksexton
[@m00gs]: https://github.com/m00gs
[@maniacal]: https://github.com/maniacal
[@mrheath]: https://github.com/mrheath
[@nellshamrell]: https://github.com/nellshamrell
[@nictrix]: https://github.com/nictrix
[@s3lehtin]: https://github.com/s3lehtin
[@shinka81]: https://github.com/shinka81
[@walterdolce]: https://github.com/walterdolce
[@xmik]: https://github.com/xmik
[code climate coverage]:
  https://codeclimate.com/github/newcontext-oss/kitchen-terraform
[travis ci build plan]: https://travis-ci.com/newcontext-oss/kitchen-terraform
[terraform-issue-17655]: https://github.com/hashicorp/terraform/issues/17655
[terraform-driver]:
  https://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Driver/Terraform
[terraform-verifier]:
  http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Verifier/Terraform
[#351]: https://github.com/newcontext-oss/kitchen-terraform/issues/351
