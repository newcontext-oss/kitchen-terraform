#!/usr/bin/env bash

# install TerraForm Local Provider
FILE=terraform-provider-local_1.4.0_linux_amd64.zip
URL="https://releases.hashicorp.com/terraform-provider-local/1.4.0/$FILE"
SHASUM=ca9fe963f261236b3f3308f8b4979cdd95dd68281b00c1c18a6d17db07519ac8

mkdir -p "$PLUGIN_DIRECTORY"
curl --remote-name --silent $URL
shasum -a 256 $FILE | grep $SHASUM
unzip $FILE -d "$PLUGIN_DIRECTORY"
