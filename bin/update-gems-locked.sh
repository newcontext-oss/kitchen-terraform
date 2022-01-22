#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
set +x
chruby ruby-3.0
ruby --version
set -x
gem install bundler
if [ -e gems.locked ]
then
  bundle update --all
else
  bundle install
fi
bundle binstubs --force bundler guard middleman-cli pry rake reek rspec-core rufo test-kitchen yard
set +x
