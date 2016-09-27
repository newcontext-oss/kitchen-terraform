#!/usr/bin/env bash

echo "Enter AWS ACCESS KEY"
read aws_access_key

echo "Enter AWS SECRET KEY"
read aws_secret_key

version=`grep "VERSION" ../../lib/terraform/version.rb | awk '{print $3}' | tr -d "'"`

read -r -d '' command <<'EOF'
  read -r -d '' kitchen_local <<'EOK'
---
transport:
  ssh_key: ~/.ssh/id_rsa
suites:
  - name: example
    provisioner:
      variables:
        - access_key=<%= ENV['AWS_ACCESS_KEY'] %>
        - public_key_pathname=~/.ssh/id_rsa.pub
        - secret_key=<%= ENV['AWS_SECRET_KEY'] %>
EOK

  branch="ncs-alane-0.3.0"
  wget https://github.com/newcontext/kitchen-terraform/archive/${branch}.zip && \
  unzip ${branch}.zip && \
  cd kitchen-terraform-${branch}/examples/detailed && \
  /usr/bin/ssh-keygen -P '' -f ~/.ssh/id_rsa && \
  echo "$kitchen_local" > .kitchen.local.yml && \
  mkdir -p .kitchen/kitchen-terraform/example-ubuntu && \
  /usr/local/bundle/bin/kitchen test --destroy always
EOF

docker run -it -e "AWS_ACCESS_KEY=${aws_access_key}" \
  -e "AWS_SECRET_KEY=${aws_secret_key}" \
  kitchen-terraform:$version /bin/bash -c "${command}"
