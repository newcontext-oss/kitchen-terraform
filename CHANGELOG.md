# Change Log

All notable changes to this project will be documented in this file; the
format is based on [Keep a CHANGELOG].

This project adheres to [Semantic Versioning] with the exception that
major version 0.y.z will maintain a stable public interface.

## [0.6.0] - 2017-xx-yy

### Changed

* Restructured code for better distribution of responsibilities

* Intermediate workflow Terraform commands will be logged at the debug
  level

### Fixed

* Broken reference to the Getting Started guide (thanks [@nellshamrell])

* Output names for Terraform 0.6 are correctly parsed

* Incomplete InSpec control definition in the Getting Started guide (
  thanks [@burythehammer])

## [0.5.1] - 2017-02-17

### Fixed

* Support for Terraform configurations that do not define any outputs
  (thanks [@johnrengelman])

## [0.5.0] - 2017-01-09

### Added

* Support for Terraform v0.8

* Support for Ruby 2.4

### Fixed

* Docker provider example's group controls configuration

## [0.4.0] - 2016-12-24

### Added

* A shiny, new logo (thanks [@ksexton])

* A shiny, new [Travis CI build plan] (thanks [@justindossey])

* Support for Ruby 2.1 and 2.2 (thanks [@mrmarbury] and [@m00gs])

* [Code Climate coverage]

* Group attributes default to a mapping of all Terraform output
  variables to equivalently named InSpec attributes (thanks [@shinka81])

* A Docker provider example (thanks [@errygg])

* An OpenStack provider example (thanks [@xmik])

* Groups with no hostnames will have their controls executed locally; in
  theory, this enables testing of any provider API

* Provisioner configuration for the `terraform apply -parallelism`
  option (thanks [@s3lehtin])

* Clay Thomas, Ewa Czechowska, Erik R. Rygg, Kyle Sexton, and Walter
  Dolce join the gem specification authors

### Changed

* Removed the pin on the RubyGems version from the gem specification
  (thanks [@jbussdieker])

### Fixed

* Use the current version in the Gemfile example (thanks [@walterdolce])

## [0.3.0] - 2016-10-04

### Added

* Support for Terraform v0.7 (thanks [@esword], [@maniacal], and
  [@nictrix])

* Getting started guide under `examples/getting_started` (thanks
  [@nellshamrell])

* Kevin Dickerson, Nell Shamrell-Harrington, and Michael Glenney join
  the gem specification authors

### Changed

* Example project moved under `examples/detailed` (thanks
  [@nellshamrell])

* Deprecate support for Terraform v0.6

### Fixed

* Release date of kitchen-terraform v0.2.0

* Remove references to verifying the gem; it's problematic even with
  low security (thanks [@kevindickerson])

## [0.2.0] - 2016-09-12

### Added

* Live log stream of output from Terraform commands

* Coercion and validation of configuration values

* Configuration option for timeout of Terraform apply command

* Configuration option for colored output of Terraform plan and apply
  commands (thanks [@nictrix])

* Configuration of variable assignments using a map

* Getting started guide (thanks [@nellshamrell])

### Changed

* CHANGELOG format is based on [Keep a CHANGELOG] \(thanks [@amaltson]\)

* Gem specification email address (thanks [@mrheath])

* Example project automatically waits for remote SSH to be available

* Improve error handling and messages (thanks [@cullenmcdermott])

* Deprecate configuration of variable assignments using a list or string

### Fixed

* Inspec is pinned at the minor feature level to reduce bug risk

## [0.1.2] - 2016-08-04

### Added

* Link to referenced users' profiles in the Change Log

* Display RuboCop Cop names in Guard output

* Contributing and developing guides (thanks [@nictrix])

* Example instructions suggest IAM user creation for enhanced security (
  thanks [@nictrix])

### Changed

* Example configuration is compatible with more AWS accounts (thanks
  [@nictrix])

### Fixed

* Remove enforcement of RubyGems trust policy (thanks [@fivetwentysix])

* Only suggest the LowSecurity RubyGems trust policy; in a clean Bundler
  environment, this is the highest policy that can be successfully
  applied

* Only enforce code coverage requirements when Guard runs all specs

## [0.1.1] - 2016-07-26

### Added

### Changed

* Replace `0 == fixnum_object` with `fixnum_object.zero?`

* Include LICENSE and README in the gem

* Remove specs from the gem

* Add Nick Willever to the gem specification authors

### Fixed

* Lower the development bundle trust policy to MediumSecurity due to
  rubocop-0.42.0 not being signed :crying_cat_face:

* Fix the line length of the gem specification signing key configuration

* Correct the reference to `bundle install --trust-profile` with
  `bundle install --trust-policy` in the README (thanks [@nellshamrell]
  and [@nictrix])

* Clarify the gem installation instructions in the README (thanks
  [@nictrix])

## 0.1.0 - 2016-07-22

### Added

* Initial release

[0.1.1]: https://github.com/newcontext/kitchen-terraform/compare/v0.1.0...v0.1.1
[0.1.2]: https://github.com/newcontext/kitchen-terraform/compare/v0.1.1...v0.1.2
[0.2.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.1.2...v0.2.0
[0.3.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.2.0...v0.3.0
[0.4.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.3.0...v0.4.0
[0.5.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.4.0...v0.5.0
[0.5.1]: https://github.com/newcontext/kitchen-terraform/compare/v0.5.0...v0.5.1
[0.6.0]: https://github.com/newcontext/kitchen-terraform/compare/v0.5.0...v0.6.0
[@amaltson]: https://github.com/amaltson
[@burythehammer]: https://github.com/burythehammer
[@cullenmcdermott]: https://github.com/cullenmcdermott
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
[Code Climate coverage]: https://codeclimate.com/github/newcontext-oss/kitchen-terraform
[Keep a CHANGELOG]: http://keepachangelog.com/
[Semantic Versioning]: http://semver.org/
[Travis CI build plan]: https://travis-ci.org/newcontext-oss/kitchen-terraform
