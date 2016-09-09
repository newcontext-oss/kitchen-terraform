# Change Log

All notable changes to this project will be documented in this file; the
format is based on [Keep a CHANGELOG].

This project adheres to [Semantic Versioning] with the exception that
major version 0.y.z will maintain a stable public interface.

## [0.2.0] - 2016-09-??

### Added

* Live log stream of output from Terraform commands

* Coercion and validation of configuration values

* Configuration option for timeout of Terraform apply command

* Configuration option for colored output of Terroform plan and apply
  commands (thanks [@nictrix])

* Getting started guide (thanks [@nellshamrell])

### Changed

* CHANGELOG format is based on [Keep a CHANGELOG] \(thanks [@amaltson]\)

* Gem specification email address (thanks [@mrheath])

* Example project automatically waits for remote SSH to be available

* Improve error handling and messages (thanks [@cullenmcdermott])

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
[@amaltson]: https://github.com/amaltson
[@cullenmcdermott]: https://github.com/cullenmcdermott
[@fivetwentysix]: https://github.com/fivetwentysix
[@mrheath]: https://github.com/mrheath
[@nellshamrell]: https://github.com/nellshamrell
[@nictrix]: https://github.com/nictrix
[Keep a CHANGELOG]: http://keepachangelog.com/
[Semantic Versioning]: http://semver.org/
