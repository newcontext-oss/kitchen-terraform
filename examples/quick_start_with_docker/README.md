# Quick Start

An example of using a Docker container to orchestrate the testing of
Terraform code with kitchen-terraform

## Build the container

```sh
version=`grep "VERSION" ../../lib/terraform/version.rb | awk '{print $3}' | tr -d "'"`
docker build -t kitchen-terraform:$version .                                                                                   
```

## Run the detailed example

```sh
./run_detailed.sh
```

## Run on a local Terraform project

```sh
docker run -it -v ${pwd}:/opt/kitchen-terraform \
/usr/local/bundle/bin/kitchen test --destroy always
```
