gem install bundler --conservative --minimal-deps --no-document --version=`"~>2.0`"
if (! $?) {
    Write-Error "Failed installing bundler"
    exit 1
}
$GEMFILEDIR = $Env:GEMFILE_DIR
bundle config --local gemfile "${GEMFILEDIR}/gems.rb"
bundle config --local jobs $(nproc --ignore=1)
bundle config --local set clean true
bundle config --local set specific_platform true

# this would force a gems.locked file to exist, not for gems!
# bundle config --local deployment true
bundle config --local deployment false

# bundle config --local set frozen true
bundle config --local set frozen false
