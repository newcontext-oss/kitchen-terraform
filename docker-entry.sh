#!/bin/ash

# This set's gems in our path, which is useful for things like awsspec
export GEM_HOME=/usr/local/bundle
export PATH=$GEM_HOME/bin:$PATH
$@