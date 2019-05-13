#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
chruby $1
if [ -e .bundle/config ]
then
  rm .bundle/config
fi
bundle config --local gemfile $1/Gemfile

