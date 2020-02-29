#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
set +x
for RUBY in ruby-2.6 ruby-2.5 ruby-2.4
do
  chruby "$RUBY"
  if [ "$RUBY" != "ruby-2.6" ]
  then
    pushd "$RUBY"
  fi
  ruby --version
  set -x
  if [ -e gems.locked ]
  then
    bundle update --all
  else
    bundle install
  fi
  bundle clean
  bundle binstubs --force bundler guard middleman-cli pry rake reek rspec-core rufo test-kitchen travis yard
  set +x
  if [ "$RUBY" != "ruby-2.6" ]
  then
    popd
  fi
done
