#! /usr/bin/env bash

mkdir -p test/assests
ssh-keygen -b 4096 -C "Kitchen-Terraform AWS provider tutorial" -f test/assets/key_pair -N "" -t rsa
