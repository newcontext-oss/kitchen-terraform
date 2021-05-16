#!/usr/bin/env bash

# install TerraGrunt
FILE1=terragrunt_linux_amd64
URL2=https://github.com/gruntwork-io/terragrunt/releases/download/v0.18.6
URL2="$URL2/$FILE1"
SHASUM2=611acfa3b65413dd95d56c48ae72577d8b890ed8fdee7b199630b5f3f4c88a99

curl --location --remote-name --silent $URL2
shasum -a 256 $FILE1 | grep $SHASUM2
chmod +x $FILE1

# install TerraForm Local Provider
FILE2=terraform-provider-local_1.4.0_linux_amd64.zip
URL3=https://releases.hashicorp.com/terraform-provider-local/1.4.0
URL3="$URL3/$FILE2"
SHASUM3=ca9fe963f261236b3f3308f8b4979cdd95dd68281b00c1c18a6d17db07519ac8

PLUGIN_DIR='test/terraform/11/PlugIns/PlugInDirectory'
MAJOR_VERSION=$(echo $TERRAFORM_VERSION|sed 's/0\.\([0-9][0-9]*\)\.[0-9][0-9]*$/\1/')
if [ "$MAJOR_VERSION" -ge 13 ]; then
  PLUGIN_DIR="${PLUGIN_DIR}/registry.terraform.io/hashicorp/local/1.4.0/linux_amd64"
fi
mkdir -p "$PLUGIN_DIR"
curl --remote-name --silent $URL3
shasum -a 256 $FILE2 | grep $SHASUM3
unzip $FILE2 -d "$PLUGIN_DIR"

