#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
set +x
for RUBY in ruby-2.6 ruby-2.5 ruby-2.4
do
  chruby "$RUBY"
  ruby --version
  set -x
  export BUNDLE_GEMFILE="$RUBY"/Gemfile
  if [ -e "$RUBY"/Gemfile.lock ]
  then
    bundle update
    bundle clean
  else
    bundle install
  fi
  set +x
done
