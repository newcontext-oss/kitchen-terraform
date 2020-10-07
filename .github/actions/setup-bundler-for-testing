#!/usr/bin/env bash

gem install bundler --conservative --minimal-deps --no-document \
  --version="~>2.0"
bundle config --local gemfile "${GEMFILE_DIR}/gems.rb"
bundle config --local deployment true
bundle config --local jobs $(nproc --ignore=1)
bundle config --local set clean true
bundle config --local set frozen true
