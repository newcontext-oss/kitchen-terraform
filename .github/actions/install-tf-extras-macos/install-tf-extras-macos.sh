#!/usr/bin/env bash

# install TerraGrunt
FILE1=terragrunt_darwin_amd64
URL1="https://github.com/gruntwork-io/terragrunt/releases/download/v0.18.6/$FILE1"
SHASUM1=234327294a07c312e7bc279ea749a653218c37d2d0b51c5cf2076fcf82dc298a

curl --location --remote-name --silent $URL1
shasum -a 256 $FILE1 | grep $SHASUM1
chmod +x $FILE1

# install TerraForm Local Provider
FILE2=terraform-provider-local_1.4.0_darwin_amd64.zip
URL2="https://releases.hashicorp.com/terraform-provider-local/1.4.0/$FILE2"
SHASUM2=7ef13da7e8ae7129fae8a9c72845d52d4586db496359228ed435aeab2f44aea8

mkdir -p "$PLUGIN_DIRECTORY"
curl --remote-name --silent $URL2
shasum -a 256 $FILE2 | grep $SHASUM2
unzip $FILE2 -d "$PLUGIN_DIRECTORY"
