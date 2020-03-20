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
  bundle binstubs --force rake test-kitchen
  set +x
  popd
done
