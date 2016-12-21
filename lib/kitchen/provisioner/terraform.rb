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

require 'kitchen'
require 'terraform/apply_timeout_config'
require 'terraform/color_config'
require 'terraform/configurable'
require 'terraform/directory_config'
require 'terraform/parallelism_config'
require 'terraform/plan_config'
require 'terraform/state_config'
require 'terraform/variable_files_config'
require 'terraform/variables_config'

module Kitchen
  module Provisioner
    # Terraform configuration applier
    class Terraform < Base
      include ::Terraform::ApplyTimeoutConfig

      include ::Terraform::ColorConfig

      include ::Terraform::Configurable

      include ::Terraform::DirectoryConfig

      include ::Terraform::ParallelismConfig

      include ::Terraform::PlanConfig

      include ::Terraform::StateConfig

      include ::Terraform::VariableFilesConfig

      include ::Terraform::VariablesConfig

      kitchen_provisioner_api_version 2

      def call(_state = nil)
        driver.validate_configuration_files
        driver.download_modules
        driver.plan_execution destroy: false
        driver.apply_execution_plan
      end
    end
  end
end
