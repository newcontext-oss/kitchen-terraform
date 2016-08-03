# kitchen-terraform Change Log

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

[@nellshamrell]: https://github.com/nellshamrell

[@nictrix]: https://github.com/nictrix
