#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
echo ruby-2.6
chruby ruby-2.6
set -x
gem update --system
gem install --version="~> 2.0" bundler
gem install debride fasterer rcodetools fastri reek

