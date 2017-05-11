# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "kitchen/config/cli"
require "terraform/configurable"

# Terraform state lifecycle activities manager
::Kitchen::Driver::Terraform = ::Class.new ::Kitchen::Driver::Base
::Kitchen::Driver::Terraform.kitchen_driver_api_version 2
# FIXME: should concurrency be disabled to prevent problems from using the same plan or state files?
::Kitchen::Driver::Terraform.no_parallel_for
::Kitchen::Config::CLI.call plugin_class: ::Kitchen::Driver::Terraform
::Kitchen::Driver::Terraform.send :include, ::Terraform::Configurable

require "kitchen/driver/terraform/create"
require "kitchen/driver/terraform/destroy"
require "kitchen/driver/terraform/verify_dependencies"

::Kitchen::Driver::Terraform.send :define_method, :create, ::Kitchen::Driver::Terraform::Create
::Kitchen::Driver::Terraform.send :define_method, :destroy, ::Kitchen::Driver::Terraform::Destroy
::Kitchen::Driver::Terraform.send :define_method, :verify_dependencies, ::Kitchen::Driver::Terraform::VerifyDependencies
