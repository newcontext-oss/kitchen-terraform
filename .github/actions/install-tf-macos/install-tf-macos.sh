#!/usr/bin/env bash

# install Terraform
FILE1=terraform_${TERRAFORM_VERSION}_darwin_amd64.zip
URL1=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}
URL1="$URL1/$FILE1"

curl --remote-name --silent $URL1
shasum -a 256 $FILE1 | grep ${TERRAFORM_SHASUM}
unzip $FILE1 -d "$HOME/bin"

# install TerraGrunt
FILE2=terragrunt_darwin_amd64
URL2=https://github.com/gruntwork-io/terragrunt/releases/download/v0.18.6
URL2="$URL2/$FILE2"
SHASUM2=234327294a07c312e7bc279ea749a653218c37d2d0b51c5cf2076fcf82dc298a

curl --location --remote-name --silent $URL2
shasum -a 256 $FILE2 | grep $SHASUM2
chmod +x $FILE2

# install TerraForm Provider
FILE3=terraform-provider-local_1.2.2_darwin_amd64.zip
URL3=https://releases.hashicorp.com/terraform-provider-local/1.2.2
URL3="$URL3/$FILE3"
SHASUM3=2464abf56aabecca26177f3562a4bd771cd79a79a94c78474f39691f9d4abea7

case $TERRAFORM_VERSION in
     "0.12.0") PLUGIN_DIR='test/terraform/11/PlugIns/Plug In Directory';;
     "0.13.0") PLUGIN_DIR='test/terraform/Plug Ins/Plug In Directory'
               PLUGIN_DIR="$PLUGIN_DIR/registry.terraform.io/hashicorp'
	       PLUGIN_DIR="$PLUGIN_DIR/local";;
esac
curl --remote-name --silent $URL3
shasum -a 256 $FILE3 | grep $SHASUM3
unzip $FILE3 -d $PLUGIN_DIR
