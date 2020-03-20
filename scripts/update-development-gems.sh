#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
set +x
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
