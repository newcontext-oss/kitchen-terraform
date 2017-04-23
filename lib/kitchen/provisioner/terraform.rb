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
require 'terraform/file_configs'
require 'terraform/parallelism_config'
require 'terraform/variable_files_config'
require 'terraform/variables_config'

module Kitchen
  module Provisioner
    # Applies constructive Terraform plans
    class Terraform < ::Kitchen::Provisioner::Base
      extend ::Terraform::ApplyTimeoutConfig

      extend ::Terraform::ColorConfig

      extend ::Terraform::DirectoryConfig

      extend ::Terraform::FileConfigs

      extend ::Terraform::ParallelismConfig

      extend ::Terraform::VariableFilesConfig

      extend ::Terraform::VariablesConfig

      include ::Terraform::Configurable

      kitchen_provisioner_api_version 2

      def call(_state = nil)
        client.apply_constructively
      rescue ::Kitchen::StandardError, ::SystemCallError => error
        raise ::Kitchen::ActionFailed, error.message
      end
    end
  end
end
