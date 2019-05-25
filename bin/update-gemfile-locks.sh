#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
set +x
for RUBY in ruby-2.6 ruby-2.5 ruby-2.4
do
  chruby "$RUBY"
  ruby --version
  set -x
  if [ -e "$RUBY"/Gemfile.lock ]
  then
    bundle update --gemfile "$RUBY"/Gemfile
  else
    bundle install --gemfile "$RUBY"/Gemfile
  fi
  set +x
done
