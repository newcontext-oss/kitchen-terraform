#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
set +x
for RUBY in ruby-2.6 ruby-2.5 ruby-2.4
do
  chruby "$RUBY"
  pushd "$RUBY"
  ruby --version
  set -x
  if [ -e gems.locked ]
  then
    bundle update --all
  else
    bundle install
  fi
  bundle clean
  bundle binstubs bundler guard middleman-cli rake reek rspec-core rufo test-kitchen yard
  set +x
  popd
done
