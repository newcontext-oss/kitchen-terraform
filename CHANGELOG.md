# kitchen-terraform Change Log

## Version 0.1.2

### Patch

* Remove enforcement of RubyGems trust policy (thanks [@fivetwentysix])

* Only suggest the LowSecurity RubyGems trust policy; in a clean Bundler
  environment, this is the highest policy that can be successfully
  applied

* Add links to referenced users' profiles in the Change Log

* Display RuboCop Cop names in Guard output

* Only enforce code coverage requirements when Guard runs all specs

* Add contributing and developing guides (thanks @nictrix)

* Update example configuration to be compatible with more AWS accounts
  (thanks @nictrix)

* Update example instructions to suggest IAM user creation for enhanced
  security (thanks @nictrix)

## Version 0.1.1

### Patch

* Lower the development bundle trust policy to MediumSecurity due to
  rubocop-0.42.0 not being signed :crying_cat_face:

* Replace `0 == fixnum_object` with `fixnum_object.zero?`

* Add the LICENSE and README to the gem

* Remove the specs from the gem

* Fix the line length of the gem specification signing key configuration

* Correct the reference to `bundle install --trust-profile` with
  `bundle install --trust-policy` in the README (thanks to
  [@nellshamrell] and [@nictrix])

* Clarify the gem installation instructions in the README (thanks to
  [@nictrix])

* Add Nick Willever to the gem specification authors

## Version 0.1.0

### Minor

* Initial release

[@fivetwentysix]: https://github.com/fivetwentysix
[@nellshamrell]: https://github.com/nellshamrell
[@nictrix]: https://github.com/nictrix
